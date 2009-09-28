From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] /proc/net/tcp, overhead removed
Date: Tue, 29 Sep 2009 00:20:07 +0200
Message-ID: <4AC13697.4090707@gmail.com>
References: <1254000675-8327-1-git-send-email-iler.ml@gmail.com>	 <4ABF360E.7080301@gmail.com> <f36b08ee0909281510y282d621etb4264ecd92cbe8f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Yakov Lerner <iler.ml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54635 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbZI1WUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 18:20:09 -0400
In-Reply-To: <f36b08ee0909281510y282d621etb4264ecd92cbe8f0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yakov Lerner a =E9crit :
> On Sun, Sep 27, 2009 at 12:53, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>> Yakov Lerner a =E9crit :
>>> /proc/net/tcp does 20,000 sockets in 60-80 milliseconds, with this =
patch.
>>>
>>> The overhead was in tcp_seq_start(). See analysis (3) below.
>>> The patch is against Linus git tree (1). The patch is small.
>>>
>>> ------------  -----------   ------------------------------------
>>> Before patch  After patch   20,000 sockets (10,000 tw + 10,000 esta=
b)(2)
>>> ------------  -----------   ------------------------------------
>>> 6 sec          0.06 sec     dd bs=3D1k if=3D/proc/net/tcp >/dev/nul=
l
>>> 1.5 sec        0.06 sec     dd bs=3D4k if=3D/proc/net/tcp >/dev/nul=
l
>>>
>>> 1.9 sec        0.16 sec     netstat -4ant >/dev/null
>>> ------------  -----------   ------------------------------------
>>>
>>> This is ~ x25 improvement.
>>> The new time is not dependent on read blockize.
>>> Speed of netstat, naturally, improves, too; both -4 and -6.
>>> /proc/net/tcp6 does 20,000 sockets in 100 millisec.
>>>
>>> (1) against git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/=
linux-2.6.git
>>>
>>> (2) Used 'manysock' utility to stress system with large number of s=
ockets:
>>>   "manysock 10000 10000"    - 10,000 tw + 10,000 estab ip4 sockets.
>>>   "manysock -6 10000 10000" - 10,000 tw + 10,000 estab ip6 sockets.
>>> Found at http://ilerner.3b1.org/manysock/manysock.c
>>>
>>> (3) Algorithmic analysis.
>>>     Old algorithm.
>>>
>>> During 'cat </proc/net/tcp', tcp_seq_start() is called O(numsockets=
) times (4).
>>> On average, every call to tcp_seq_start() scans half the whole hash=
table. Ouch.
>>> This is O(numsockets * hashsize). 95-99% of 'cat </proc/net/tcp' is=
 spent in
>>> tcp_seq_start()->tcp_get_idx. This overhead is eliminated by new al=
gorithm,
>>> which is O(numsockets + hashsize).
>>>
>>>     New algorithm.
>>>
>>> New algorithms is O(numsockets + hashsize). We jump to the right
>>> hash bucket in tcp_seq_start(), without scanning half the hash.
>>> To jump right to the hash bucket corresponding to *pos in tcp_seq_s=
tart(),
>>> we reuse three pieces of state (st->num, st->bucket, st->sbucket)
>>> as follows:
>>>  - we check that requested pos >=3D last seen pos (st->num), the ty=
pical case.
>>>  - if so, we jump to bucket st->bucket
>>>  - to arrive to the right item after beginning of st->bucket, we
>>> keep in st->sbucket the position corresponding to the beginning of
>>> bucket.
>>>
>>> (4) Explanation of O( numsockets * hashsize) of old algorithm.
>>>
>>> tcp_seq_start() is called once for every ~7 lines of netstat output
>>> if readsize is 1kb, or once for every ~28 lines if readsize >=3D 4k=
b.
>>> Since record length of /proc/net/tcp records is 150 bytes, formula =
for
>>> number of calls to tcp_seq_start() is
>>>             (numsockets * 150 / min(4096,readsize)).
>>> Netstat uses 4kb readsize (newer versions), or 1kb (older versions)=
=2E
>>> Note that speed of old algorithm does not improve above 4kb blocksi=
ze.
>>>
>>> Speed of the new algorithm does not depend on blocksize.
>>>
>>> Speed of the new algorithm does not perceptibly depend on hashsize =
(which
>>> depends on ramsize). Speed of old algorithm drops with bigger hashs=
ize.
>>>
>>> (5) Reporting order.
>>>
>>> Reporting order is exactly same as before if hash does not change u=
nderfoot.
>>> When hash elements come and go during report, reporting order will =
be
>>> same as that of tcpdiag.
>>>
>>> Signed-off-by: Yakov Lerner <iler.ml@gmail.com>
>>> ---
>>>  net/ipv4/tcp_ipv4.c |   26 ++++++++++++++++++++++++--
>>>  1 files changed, 24 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>>> index 7cda24b..7d9421a 100644
>>> --- a/net/ipv4/tcp_ipv4.c
>>> +++ b/net/ipv4/tcp_ipv4.c
>>> @@ -1994,13 +1994,14 @@ static inline int empty_bucket(struct tcp_i=
ter_state *st)
>>>               hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].twc=
hain);
>>>  }
>>>
>>> -static void *established_get_first(struct seq_file *seq)
>>> +static void *established_get_first_after(struct seq_file *seq, int=
 bucket)
>>>  {
>>>       struct tcp_iter_state *st =3D seq->private;
>>>       struct net *net =3D seq_file_net(seq);
>>>       void *rc =3D NULL;
>>>
>>> -     for (st->bucket =3D 0; st->bucket < tcp_hashinfo.ehash_size; =
++st->bucket) {
>>> +     for (st->bucket =3D bucket; st->bucket < tcp_hashinfo.ehash_s=
ize;
>>> +          ++st->bucket) {
>>>               struct sock *sk;
>>>               struct hlist_nulls_node *node;
>>>               struct inet_timewait_sock *tw;
>>> @@ -2036,6 +2037,11 @@ out:
>>>       return rc;
>>>  }
>>>
>>> +static void *established_get_first(struct seq_file *seq)
>>> +{
>>> +     return established_get_first_after(seq, 0);
>>> +}
>>> +
>>>  static void *established_get_next(struct seq_file *seq, void *cur)
>>>  {
>>>       struct sock *sk =3D cur;
>>> @@ -2045,6 +2051,7 @@ static void *established_get_next(struct seq_=
file *seq, void *cur)
>>>       struct net *net =3D seq_file_net(seq);
>>>
>>>       ++st->num;
>>> +     st->sbucket =3D st->num;
>> Hello Yakov
>>
>> Intention of your patch is very good, but not currently working.
>>
>> It seems you believe there is at most one entry per hash slot or som=
ething like that
>>
>> Please reboot your test machine with "thash_entries=3D4096" so that =
tcp hash
>> size is 4096, and try to fill 20000 tcp sockets with a test program.
>>
>> then :
>>
>> # ss | wc -l
>> 20001
>> (ok)
>>
>> # cat /proc/net/tcp | wc -l
>> 22160
>> (not quite correct ...)
>>
>> # netstat -tn | wc -l
>> <never ends>
>>
>>
>> # dd if=3D/proc/net/tcp ibs=3D1024 | wc -l
>> <never ends>
>>
>>
>> Please send your next patch on netdev@vger.kernel.org , DaveM only ,=
 were netdev people
>> are reviewing netdev patches, there is no need include other people =
for first submissions.
>>
>> Thank you
>>
>>
>> #include <sys/types.h>
>> #include <sys/socket.h>
>> #include <netinet/in.h>
>> #include <string.h>
>> int fdlisten;
>> main()
>> {
>>        int i;
>>        struct sockaddr_in sockaddr;
>>
>>        fdlisten =3D socket(AF_INET, SOCK_STREAM, 0);
>>        memset(&sockaddr, 0, sizeof(sockaddr));
>>        sockaddr.sin_family =3D AF_INET;
>>        sockaddr.sin_port =3D htons(2222);
>>        if (bind(fdlisten, (struct sockaddr *)&sockaddr, sizeof(socka=
ddr))=3D=3D -1) {
>>                perror("bind");
>>                return 1;
>>        }
>>        if (listen(fdlisten, 10)=3D=3D -1) {
>>                perror("listen");
>>                return 1;
>>        }
>>        if (fork() =3D=3D 0) {
>>                while (1) {
>>                        socklen_t len =3D sizeof(sockaddr);
>>                        int newfd =3D accept(fdlisten, (struct sockad=
dr *)&sockaddr, &len);
>>                }
>>        }
>>        for (i =3D 0 ; i < 10000; i++) {
>>                int fd =3D socket(AF_INET, SOCK_STREAM, 0);
>>                if (fd =3D=3D -1) {
>>                        perror("socket");
>>                        break;
>>                        }
>>                connect(fd, (struct sockaddr *)&sockaddr, sizeof(sock=
addr));
>>        }
>>        pause();
>> }
>>
>=20
> Hello Eric,
>=20
> I found the problem, thanks. I'll re-send after testing.

OK good !

>=20
> In the meantime, I'd like to ask you whether it makes sense to
> add the /proc/net entry, to switch between "old way" and "new way".
> The switch would allow quick compare/test between new way and
> old way not only by line count, but by full contents, without reboot.
>=20

Well, this switch wont be needed for patch validation, but it might hel=
p
you to test your patch of course.

Actually I found the error reading your patch, and I made a quick test =
to
confirm my understanding :)

See you tomorrow, its rather late here :)
