From: Yakov Lerner <iler.ml@gmail.com>
Subject: Re: [PATCH] /proc/net/tcp, overhead removed
Date: Tue, 29 Sep 2009 01:10:18 +0300
Message-ID: <f36b08ee0909281510y282d621etb4264ecd92cbe8f0@mail.gmail.com>
References: <1254000675-8327-1-git-send-email-iler.ml@gmail.com>
	 <4ABF360E.7080301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:59343 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbZI1WKQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 18:10:16 -0400
Received: by fxm18 with SMTP id 18so4047749fxm.17
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2009 15:10:20 -0700 (PDT)
In-Reply-To: <4ABF360E.7080301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 27, 2009 at 12:53, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Yakov Lerner a =E9crit :
>> /proc/net/tcp does 20,000 sockets in 60-80 milliseconds, with this p=
atch.
>>
>> The overhead was in tcp_seq_start(). See analysis (3) below.
>> The patch is against Linus git tree (1). The patch is small.
>>
>> ------------ =A0----------- =A0 ------------------------------------
>> Before patch =A0After patch =A0 20,000 sockets (10,000 tw + 10,000 e=
stab)(2)
>> ------------ =A0----------- =A0 ------------------------------------
>> 6 sec =A0 =A0 =A0 =A0 =A00.06 sec =A0 =A0 dd bs=3D1k if=3D/proc/net/=
tcp >/dev/null
>> 1.5 sec =A0 =A0 =A0 =A00.06 sec =A0 =A0 dd bs=3D4k if=3D/proc/net/tc=
p >/dev/null
>>
>> 1.9 sec =A0 =A0 =A0 =A00.16 sec =A0 =A0 netstat -4ant >/dev/null
>> ------------ =A0----------- =A0 ------------------------------------
>>
>> This is ~ x25 improvement.
>> The new time is not dependent on read blockize.
>> Speed of netstat, naturally, improves, too; both -4 and -6.
>> /proc/net/tcp6 does 20,000 sockets in 100 millisec.
>>
>> (1) against git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/l=
inux-2.6.git
>>
>> (2) Used 'manysock' utility to stress system with large number of so=
ckets:
>> =A0 "manysock 10000 10000" =A0 =A0- 10,000 tw + 10,000 estab ip4 soc=
kets.
>> =A0 "manysock -6 10000 10000" - 10,000 tw + 10,000 estab ip6 sockets=
=2E
>> Found at http://ilerner.3b1.org/manysock/manysock.c
>>
>> (3) Algorithmic analysis.
>> =A0 =A0 Old algorithm.
>>
>> During 'cat </proc/net/tcp', tcp_seq_start() is called O(numsockets)=
 times (4).
>> On average, every call to tcp_seq_start() scans half the whole hasht=
able. Ouch.
>> This is O(numsockets * hashsize). 95-99% of 'cat </proc/net/tcp' is =
spent in
>> tcp_seq_start()->tcp_get_idx. This overhead is eliminated by new alg=
orithm,
>> which is O(numsockets + hashsize).
>>
>> =A0 =A0 New algorithm.
>>
>> New algorithms is O(numsockets + hashsize). We jump to the right
>> hash bucket in tcp_seq_start(), without scanning half the hash.
>> To jump right to the hash bucket corresponding to *pos in tcp_seq_st=
art(),
>> we reuse three pieces of state (st->num, st->bucket, st->sbucket)
>> as follows:
>> =A0- we check that requested pos >=3D last seen pos (st->num), the t=
ypical case.
>> =A0- if so, we jump to bucket st->bucket
>> =A0- to arrive to the right item after beginning of st->bucket, we
>> keep in st->sbucket the position corresponding to the beginning of
>> bucket.
>>
>> (4) Explanation of O( numsockets * hashsize) of old algorithm.
>>
>> tcp_seq_start() is called once for every ~7 lines of netstat output
>> if readsize is 1kb, or once for every ~28 lines if readsize >=3D 4kb=
=2E
>> Since record length of /proc/net/tcp records is 150 bytes, formula f=
or
>> number of calls to tcp_seq_start() is
>> =A0 =A0 =A0 =A0 =A0 =A0 (numsockets * 150 / min(4096,readsize)).
>> Netstat uses 4kb readsize (newer versions), or 1kb (older versions).
>> Note that speed of old algorithm does not improve above 4kb blocksiz=
e.
>>
>> Speed of the new algorithm does not depend on blocksize.
>>
>> Speed of the new algorithm does not perceptibly depend on hashsize (=
which
>> depends on ramsize). Speed of old algorithm drops with bigger hashsi=
ze.
>>
>> (5) Reporting order.
>>
>> Reporting order is exactly same as before if hash does not change un=
derfoot.
>> When hash elements come and go during report, reporting order will b=
e
>> same as that of tcpdiag.
>>
>> Signed-off-by: Yakov Lerner <iler.ml@gmail.com>
>> ---
>> =A0net/ipv4/tcp_ipv4.c | =A0 26 ++++++++++++++++++++++++--
>> =A01 files changed, 24 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index 7cda24b..7d9421a 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -1994,13 +1994,14 @@ static inline int empty_bucket(struct tcp_it=
er_state *st)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_nulls_empty(&tcp_hashinfo.ehash[st=
->bucket].twchain);
>> =A0}
>>
>> -static void *established_get_first(struct seq_file *seq)
>> +static void *established_get_first_after(struct seq_file *seq, int =
bucket)
>> =A0{
>> =A0 =A0 =A0 struct tcp_iter_state *st =3D seq->private;
>> =A0 =A0 =A0 struct net *net =3D seq_file_net(seq);
>> =A0 =A0 =A0 void *rc =3D NULL;
>>
>> - =A0 =A0 for (st->bucket =3D 0; st->bucket < tcp_hashinfo.ehash_siz=
e; ++st->bucket) {
>> + =A0 =A0 for (st->bucket =3D bucket; st->bucket < tcp_hashinfo.ehas=
h_size;
>> + =A0 =A0 =A0 =A0 =A0++st->bucket) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sock *sk;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct hlist_nulls_node *node;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct inet_timewait_sock *tw;
>> @@ -2036,6 +2037,11 @@ out:
>> =A0 =A0 =A0 return rc;
>> =A0}
>>
>> +static void *established_get_first(struct seq_file *seq)
>> +{
>> + =A0 =A0 return established_get_first_after(seq, 0);
>> +}
>> +
>> =A0static void *established_get_next(struct seq_file *seq, void *cur=
)
>> =A0{
>> =A0 =A0 =A0 struct sock *sk =3D cur;
>> @@ -2045,6 +2051,7 @@ static void *established_get_next(struct seq_f=
ile *seq, void *cur)
>> =A0 =A0 =A0 struct net *net =3D seq_file_net(seq);
>>
>> =A0 =A0 =A0 ++st->num;
>> + =A0 =A0 st->sbucket =3D st->num;
>
> Hello Yakov
>
> Intention of your patch is very good, but not currently working.
>
> It seems you believe there is at most one entry per hash slot or some=
thing like that
>
> Please reboot your test machine with "thash_entries=3D4096" so that t=
cp hash
> size is 4096, and try to fill 20000 tcp sockets with a test program.
>
> then :
>
> # ss | wc -l
> 20001
> (ok)
>
> # cat /proc/net/tcp | wc -l
> 22160
> (not quite correct ...)
>
> # netstat -tn | wc -l
> <never ends>
>
>
> # dd if=3D/proc/net/tcp ibs=3D1024 | wc -l
> <never ends>
>
>
> Please send your next patch on netdev@vger.kernel.org , DaveM only , =
were netdev people
> are reviewing netdev patches, there is no need include other people f=
or first submissions.
>
> Thank you
>
>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <string.h>
> int fdlisten;
> main()
> {
> =A0 =A0 =A0 =A0int i;
> =A0 =A0 =A0 =A0struct sockaddr_in sockaddr;
>
> =A0 =A0 =A0 =A0fdlisten =3D socket(AF_INET, SOCK_STREAM, 0);
> =A0 =A0 =A0 =A0memset(&sockaddr, 0, sizeof(sockaddr));
> =A0 =A0 =A0 =A0sockaddr.sin_family =3D AF_INET;
> =A0 =A0 =A0 =A0sockaddr.sin_port =3D htons(2222);
> =A0 =A0 =A0 =A0if (bind(fdlisten, (struct sockaddr *)&sockaddr, sizeo=
f(sockaddr))=3D=3D -1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("bind");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (listen(fdlisten, 10)=3D=3D -1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("listen");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (fork() =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0socklen_t len =3D size=
of(sockaddr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int newfd =3D accept(f=
dlisten, (struct sockaddr *)&sockaddr, &len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0for (i =3D 0 ; i < 10000; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int fd =3D socket(AF_INET, SOCK_STREAM=
, 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (fd =3D=3D -1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("socket");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0connect(fd, (struct sockaddr *)&sockad=
dr, sizeof(sockaddr));
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0pause();
> }
>

Hello Eric,

I found the problem, thanks. I'll re-send after testing.

In the meantime, I'd like to ask you whether it makes sense to
add the /proc/net entry, to switch between "old way" and "new way".
The switch would allow quick compare/test between new way and
old way not only by line count, but by full contents, without reboot.

Yakov
