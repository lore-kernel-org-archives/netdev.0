From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH net.git] net: Fix recvmmsg timeout handling
Date: Fri, 15 Aug 2014 21:23:27 +0200
Message-ID: <53EE5E2F.5050001@gmail.com>
References: <20140721192131.GA3212@kernel.org> <20140721.204538.1952841990990568877.davem@davemloft.net> <20140722194851.GG20303@kernel.org> <53D8BF22.4080803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mtk.manpages@gmail.com, caitlin.bestler@gmail.com,
	chris.friesen@windriver.com, David.Laight@ACULAB.COM,
	eliedebrauwer@gmail.com, nhorman@tuxdriver.com, neleai@seznam.cz,
	paul@paul-moore.com, remi@remlab.net, steve@chygwyn.com,
	netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:49222 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbaHPDvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 23:51:18 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so3511273igd.2
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 20:51:18 -0700 (PDT)
In-Reply-To: <53D8BF22.4080803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping, Arnaldo!

On 07/30/2014 11:47 AM, Michael Kerrisk (man-pages) wrote:
> Hello Arnaldo,
>=20
> On 07/22/2014 09:48 PM, Arnaldo Carvalho de Melo wrote:
>> Em Mon, Jul 21, 2014 at 08:45:38PM -0700, David Miller escreveu:
>>> From: Arnaldo Carvalho de Melo <acme@kernel.org>
>>> Date: Mon, 21 Jul 2014 16:21:31 -0300
>>>
>>>> 	Trying to get this merged, finally. I has whas has been
>>>> discussed so far and agreed wrt the timeout handling.
>>>
>>> This gets lots of rejects against the current 'net' tree.
>>>
>>> Please respin and integrate Remi's Acked-by, thanks.
>>
>> Here it is, I think we should wait a bit till Michael (and whoever e=
lse
>> is up to test this today) can test it, Michael?
>>
>> It was done on top of:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
>>
>> from early today.
>=20
> Okay, this applied cleanly against a recent pull of the 'net' tree.
>=20
> However, the failure case that I pointed out (for the second time alr=
eady)
> in http://thread.gmane.org/gmane.linux.kernel/1711197/focus=3D6435
> is *still* failing. (Are you actually testing this case for your patc=
hes?
> It appears not.) However, this time the failure mode is slightly
> different:
>=20
>     Suppose the following scenario:
>=20
>     1. We do a recvmmsg() with 10 second timeout, asking for 5=20
>        messages.
>     2. 3 messages arrive
>     3. 6 seconds after the call, a signal handler interrupts
>        the call.
>     4. recvmmsg() returns success, telling us it got 3 messages.
>=20
>     So far, so good. But
>=20
>     5. We make a further recvmmsg() call.
>     6. That call returns immediately, with the (unknown error)=20
>        value 512 in errno. (In the previous patch version, we
>       (wrongly) got EINTR at this point.)
>=20
> I also see now a second failure mode in this patch set (I'm not
> sure if it was present in your earlier patch sets). If the
> timespec structure pointed to by 'timeout' contains {0, 0} then
> the call blocks indefinitely, whereas it should return=20
> immediately (with, I think, an EAGAIN error) if there are no
> messages.
>=20
> My test program (a modified version of the test program I=20
> posted earlier) is below. I've also added a test program that
> sends datagrams. To save some time, on the next iteration
> of your patch, could you please note which of the above
> failure modes you have tested for. Also, I think it would
> be good to include a detailed description of the expected
> semantics of the 'timeout' argument as part of the
> commit message. Then we all understand what the intended
> semantics are, and what needs to be tested. Something like=20
> this (may need fixing, if you think it is different):
>=20
> [[
> The 'timeout' argument implements three cases:
>=20
> 1) 'timeout' is NULL: the call blocks until 'vlen' datagrams
>    are received.
> 2) 'timeout' points to {0, 0}: the call (immediately) returns up to=20
>    'vlen' datagrams if they are available. If no datagrams are=20
>    available, the call returns immediately, with the error EAGAIN.
> 3) 'timeout'points to a structure in which at least one of the
>    fields is nonzero. The call blocks until either:
>  =20
>       a) the specified timeout expires
>       b) 'vlen' messages are received
>=20
>   In case (a), if one or more messages has been received,
>   the call returns the number of messages received; otherwise,
>   if no messages were received, the call fails with the error
>   EAGAIN.
>=20
> If, while blocking, the call is interrupted by a signal handler,
> then:
>=20
> * if 1 or more datagrams have been received, then those datagrams
>   are returned (and interruption by a signal handler is not
>   (directly) reported by this or any subsequent call to recvmmsg()).
> * if no datagrams have so far been received, then the call fails
>   with the error EINTR.
> ]]
>=20
> (In the cases where I mention EAGAIN above, the call could instead
> return 0, but EAGAIN seems more consistent with other APIs.)
>=20
> Of course, if we'd had such a spec to begin with, then probably
> the problems with the 'timeout' argument would have been detected
> much sooner. (But, recvmmsg() is hardly the first, nor the last,
> of many, many  examples of Linux API problems that occurred because=20
> of that omission.)
>=20
> Thanks,
>=20
> Michael
>=20
>=20
> /* t_recvmmsg.c=20
>=20
>    (C) 2014, Michael Kerrisk, Licensed under the GNU General Public L=
icense,
>    version 2 or later.
> */
> #define _GNU_SOURCE
> #include <sys/time.h>
> #include <signal.h>
> #include <sys/socket.h>
> #include <netdb.h>
> #include <sys/types.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <string.h>
> #include <errno.h>
>=20
> #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
>                         } while (0)
>=20
> static int              /* Public interfaces: inetBind() and inetList=
en() */
> createBoundSocket(const char *service, int type, socklen_t *addrlen)
> {
>     struct addrinfo hints;
>     struct addrinfo *result, *rp;
>     int sfd, s;
>=20
>     memset(&hints, 0, sizeof(struct addrinfo));
>     hints.ai_canonname =3D NULL;
>     hints.ai_addr =3D NULL;
>     hints.ai_next =3D NULL;
>     hints.ai_socktype =3D type;
>     hints.ai_family =3D AF_UNSPEC;        /* Allows IPv4 or IPv6 */
>     hints.ai_flags =3D AI_PASSIVE;        /* Use wildcard IP address =
*/
>=20
>     s =3D getaddrinfo(NULL, service, &hints, &result);
>     if (s !=3D 0)
>         return -1;
>=20
>     /* Walk through returned list until we find an address structure
>        that can be used to successfully create and bind a socket */
>=20
>     for (rp =3D result; rp !=3D NULL; rp =3D rp->ai_next) {
>         sfd =3D socket(rp->ai_family, rp->ai_socktype, rp->ai_protoco=
l);
>         if (sfd =3D=3D -1)
>             continue;                   /* On error, try next address=
 */
>=20
>         if (bind(sfd, rp->ai_addr, rp->ai_addrlen) =3D=3D 0)
>             break;                      /* Success */
>=20
>         /* bind() failed: close this socket and try next address */
>=20
>         close(sfd);
>     }
>=20
>     if (rp !=3D NULL && addrlen !=3D NULL)
>         *addrlen =3D rp->ai_addrlen;      /* Return address structure=
 size */
>=20
>     freeaddrinfo(result);
>=20
>     return (rp =3D=3D NULL) ? -1 : sfd;
> }
>=20
> static void
> handler()
> {
>     /* Just interrupt a syscall */
> }
>=20
> int
> main(int argc, char *argv[])
> {
>     int sfd, vlen, j, s;
>     struct mmsghdr *msgvecp;
>     struct timespec ts, ts_saved;
>     struct timespec *tsp;
>     struct sigaction sa;
>=20
>     if (argc < 4) {
>         fprintf(stderr, "Usage: %s port tmo-secs buf-len...\n", argv[=
0]);
>         exit(EXIT_FAILURE);
>     }
>=20
>     sfd =3D createBoundSocket(argv[1], SOCK_DGRAM, NULL);
>     if (sfd =3D=3D -1) {
>         fprintf(stderr, "Could not create server socket (%s)",
>                 strerror(errno));
>         exit(EXIT_FAILURE);
>     }
>=20
>     /* Handle a signal, so we can test behaviour when recvmmsg()
>        is interrupted by a signal */
>=20
>     sa.sa_handler =3D handler;
>     sa.sa_flags =3D 0;
>     sigemptyset(&sa.sa_mask);
>     if (sigaction (SIGQUIT, &sa, NULL) =3D=3D -1)
>         errExit("sigaction");
>=20
>     /* argv[2] specifies recvmmsg() timeout in seconds, or is '-', me=
aning
>        using NULL argument to get infinite timeout */
>=20
>     if (argv[2][0] =3D=3D '-') {
>         tsp =3D NULL;
>=20
>     } else {
>         ts.tv_sec =3D atoi(argv[2]);
>         ts.tv_nsec =3D 0;
>         ts_saved =3D ts;
>         tsp =3D &ts;
>     }
>=20
>     /* Remaining command-line arguments specify the size of recvmmsg(=
)
>        buffers */
>=20
>     /* The second argument to recvmmsg() is a pointer to an array of
>        mmsghdr structures. Each element of that array has a field,
>        'struct msghdr msg_hdr', that is used to store information fro=
m a
>        single received datagram. Among the fields in the msghdr struc=
ture
>        is a 'struct iovec *msg_iov'--that is, a pointer to a scatter/=
gather
>        I/O vector. To keep things simple for this example, our scatte=
r/gather
>        vectors always consists of a single element.
>     */
>=20
>     /* Allocate the mmssghdr vector, whose size corresponds to the
>        number of remaining command-line arguments */
>=20
>     vlen =3D argc - 3;
>=20
>     msgvecp =3D calloc(vlen, sizeof(struct mmsghdr));
>     if (msgvecp =3D=3D NULL)
>         errExit("calloc");
>=20
>     for (j =3D 0; j < vlen; j++) {
>         msgvecp[j].msg_hdr.msg_name =3D NULL;
>         msgvecp[j].msg_hdr.msg_namelen =3D 0;
>         msgvecp[j].msg_hdr.msg_control =3D NULL;
>         msgvecp[j].msg_hdr.msg_controllen =3D 0;
>=20
>         /* Allocate an iovec for this mmsghdr element. The vector
>            contains just a single item. */
>=20
>         msgvecp[j].msg_hdr.msg_iovlen =3D 1;
>=20
>         msgvecp[j].msg_hdr.msg_iov =3D malloc(sizeof(struct iovec));
>         if (msgvecp[j].msg_hdr.msg_iov =3D=3D NULL)
>             errExit("malloc");
>=20
>         /* The single iovec element contains a pointer to a buffer
>            that is sized according to the number given in the
>            corresponding command-line argument */
>=20
>         s =3D atoi(argv[j + 3]);
>         msgvecp[j].msg_hdr.msg_iov[0].iov_len =3D s;
>         msgvecp[j].msg_hdr.msg_iov[0].iov_base =3D malloc(s);
>     }
>=20
>     if (tsp !=3D NULL)
>         printf("Timespec before call =3D %ld.%09ld\n",
>                 (long) tsp->tv_sec, (long) tsp->tv_nsec);
>=20
>     /* Now we're ready to make the recvmmsg() call */
>=20
>     s =3D recvmmsg(sfd, msgvecp, vlen, 0, tsp);
>     if (s =3D=3D -1) {
>         if (errno =3D=3D EINTR)
>             printf("EINTR! (interrupted system call)\n");
>         else
>             errExit("recvmmsg");
>     }
>=20
>     printf("recvmmsg() returned %d\n", s);
>=20
>     if (tsp !=3D NULL)
>         printf("Timespec after call =3D %ld.%09ld\n",
>                 (long) tsp->tv_sec, (long) tsp->tv_nsec);
>=20
>     /* Display datagrams retrieved by recvmmsg() */
>=20
>     for (j =3D 0; j < s; j++) {
>         printf("%d: %u - %.*s\n", j,
>                 msgvecp[j].msg_len, msgvecp[j].msg_len,
>                 (char *) msgvecp[j].msg_hdr.msg_iov[0].iov_base);
>     }
>=20
> #ifdef SECOND_CALL
>     ts =3D ts_saved;
>     printf("About to make second recvmmsg() call\n");
>     if (tsp !=3D NULL)
>         printf("Timespec before call =3D %ld.%09ld\n",
>                 (long) tsp->tv_sec, (long) tsp->tv_nsec);
>=20
>     s =3D recvmmsg(sfd, msgvecp, vlen, 0, tsp);
>     if (s =3D=3D -1) {
>         if (errno =3D=3D EINTR)
>             printf("Second recvmmsg(): EINTR! (interrupted system cal=
l)\n");
>         else
>             errExit("recvmmsg");
>     }
>     printf("Second recvmmsg(): returned %d\n", s);
> #endif
>=20
>     exit(EXIT_SUCCESS);
> }
>=20
>=20
> And this test program can be used to send datagrams:
>=20
> /* id_sendto.c
>=20
>    (C) 2014, Michael Kerrisk, Licensed under the GNU General Public L=
icense,
>    version 2 or later.
> */
>=20
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <arpa/inet.h>
> #include <netdb.h>
> #include <sys/types.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <string.h>
> #include <errno.h>
>=20
> /* Create socket and connect it to the address specified by
>   'host' + 'service'/'type'. Return socket descriptor on success,
>   or -1 on error */
>=20
> static int
> inetConnect(const char *host, const char *service, int type)
> {
>     struct addrinfo hints;
>     struct addrinfo *result, *rp;
>     int sfd, s;
>=20
>     memset(&hints, 0, sizeof(struct addrinfo));
>     hints.ai_canonname =3D NULL;
>     hints.ai_addr =3D NULL;
>     hints.ai_next =3D NULL;
>     hints.ai_family =3D AF_UNSPEC;        /* Allows IPv4 or IPv6 */
>     hints.ai_socktype =3D type;
>=20
>     s =3D getaddrinfo(host, service, &hints, &result);
>     if (s !=3D 0) {
>         errno =3D ENOSYS;
>         return -1;
>     }
>=20
>     /* Walk through returned list until we find an address structure
>        that can be used to successfully connect a socket */
>=20
>     for (rp =3D result; rp !=3D NULL; rp =3D rp->ai_next) {
>         sfd =3D socket(rp->ai_family, rp->ai_socktype, rp->ai_protoco=
l);
>         if (sfd =3D=3D -1)
>             continue;                   /* On error, try next address=
 */
>=20
>         if (connect(sfd, rp->ai_addr, rp->ai_addrlen) !=3D -1)
>             break;                      /* Success */
>=20
>         /* Connect failed: close this socket and try next address */
>=20
>         close(sfd);
>     }
>=20
>     freeaddrinfo(result);
>=20
>     return (rp =3D=3D NULL) ? -1 : sfd;
> }
>=20
> int
> main(int argc, char *argv[])
> {
>     int sfd, j;
>=20
>     if (argc < 3 || strcmp(argv[1], "--help") =3D=3D 0) {
>         fprintf(stderr, "Usage: %s host port msg...\n", argv[0]);
>         exit(EXIT_FAILURE);
>     }
>=20
>     sfd =3D inetConnect(argv[1], argv[2], SOCK_DGRAM);
>=20
>     for (j =3D 3; j < argc; j++) {
>         if (send(sfd, argv[j], strlen(argv[j]), 0)
>                         !=3D strlen(argv[j]))
>             perror("sendto");
>     }
>=20
>     exit(EXIT_SUCCESS);
> }
>=20
>=20
>> - Arnaldo
>>
>> commit 93d40dc3a3266d6d4ed905b9333b6809b5fe24fc
>> Author: Arnaldo Carvalho de Melo <acme@redhat.com>
>> Date:   Fri Jul 18 15:23:44 2014 -0300
>>
>>     net: Fix recvmmsg timeout handling
>>    =20
>>     As reported by Elie de Brauwer the timeout handling in the recvm=
msg
>>     syscall had issues that boil down to it not properly passing the
>>     remaining time to each underlying recvmsg() call.
>>    =20
>>     Fix it by adding a timeout pointer to the recvmsg implementation=
s, so
>>     that it can use that using a variation of sock_rcvtimeo, that ov=
errides
>>     the value in SO_RCVTIMEO with the timeout passed, and returns th=
e
>>     remaining time in that pointer, this way each underlying recvmsg=
 call
>>     receives the remaining time.
>>    =20
>>     It ends up in most cases being just a forward of this pointer fr=
om
>>     recvmmsg to skb_recv_datagram().
>>    =20
>>     Reported-by: Elie De Brauwer <eliedebrauwer@gmail.com>
>>     Acked-by: R=C3=A9mi Denis-Courmont <remi@remlab.net>
>>     Cc: Caitlin Bestler <caitlin.bestler@gmail.com>
>>     Cc: Chris Friesen <chris.friesen@windriver.com>
>>     Cc: David Laight <David.Laight@ACULAB.COM>
>>     Cc: Elie De Brauwer <eliedebrauwer@gmail.com>
>>     Cc: Michael Kerrisk <mtk.manpages@gmail.com>
>>     Cc: Neil Horman <nhorman@tuxdriver.com>
>>     Cc: Ond=C5=99ej B=C3=ADlka <neleai@seznam.cz>
>>     Cc: Paul Moore <paul@paul-moore.com>
>>     Cc: R=C3=A9mi Denis-Courmont <remi@remlab.net>
>>     Cc: Steven Whitehouse <steve@chygwyn.com>
>>     Link: http://lkml.kernel.org/n/tip-5tupdoo5hdfci7diirv0ugli@git.=
kernel.org
>>     Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>>
>> diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
>> index 850246206b12..e5d36f815083 100644
>> --- a/crypto/algif_hash.c
>> +++ b/crypto/algif_hash.c
>> @@ -151,7 +151,7 @@ unlock:
>>  }
>> =20
>>  static int hash_recvmsg(struct kiocb *unused, struct socket *sock,
>> -			struct msghdr *msg, size_t len, int flags)
>> +			struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct alg_sock *ask =3D alg_sk(sk);
>> diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
>> index a19c027b29bd..4bde01591174 100644
>> --- a/crypto/algif_skcipher.c
>> +++ b/crypto/algif_skcipher.c
>> @@ -419,7 +419,7 @@ unlock:
>>  }
>> =20
>>  static int skcipher_recvmsg(struct kiocb *unused, struct socket *so=
ck,
>> -			    struct msghdr *msg, size_t ignored, int flags)
>> +			    struct msghdr *msg, size_t ignored, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct alg_sock *ask =3D alg_sk(sk);
>> diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket=
=2Ec
>> index 1be82284cf9d..254515f71793 100644
>> --- a/drivers/isdn/mISDN/socket.c
>> +++ b/drivers/isdn/mISDN/socket.c
>> @@ -113,7 +113,7 @@ mISDN_sock_cmsg(struct sock *sk, struct msghdr *=
msg, struct sk_buff *skb)
>> =20
>>  static int
>>  mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -		   struct msghdr *msg, size_t len, int flags)
>> +		   struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	struct sk_buff		*skb;
>>  	struct sock		*sk =3D sock->sk;
>> @@ -130,7 +130,7 @@ mISDN_sock_recvmsg(struct kiocb *iocb, struct so=
cket *sock,
>>  	if (sk->sk_state =3D=3D MISDN_CLOSED)
>>  		return 0;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err, t=
imeop);
>>  	if (!skb)
>>  		return err;
>> =20
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 3381c4f91a8c..13d12ef322f2 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -1111,7 +1111,7 @@ static int macvtap_sendmsg(struct kiocb *iocb,=
 struct socket *sock,
>> =20
>>  static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
>>  			   struct msghdr *m, size_t total_len,
>> -			   int flags)
>> +			   int flags, long *timeop)
>>  {
>>  	struct macvtap_queue *q =3D container_of(sock, struct macvtap_queu=
e, sock);
>>  	int ret;
>> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
>> index 6c9c16d76935..dc82dee82548 100644
>> --- a/drivers/net/ppp/pppoe.c
>> +++ b/drivers/net/ppp/pppoe.c
>> @@ -963,7 +963,7 @@ static const struct ppp_channel_ops pppoe_chan_o=
ps =3D {
>>  };
>> =20
>>  static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -		  struct msghdr *m, size_t total_len, int flags)
>> +		  struct msghdr *m, size_t total_len, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct sk_buff *skb;
>> @@ -975,7 +975,7 @@ static int pppoe_recvmsg(struct kiocb *iocb, str=
uct socket *sock,
>>  	}
>> =20
>>  	skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>> -				flags & MSG_DONTWAIT, &error);
>> +				flags & MSG_DONTWAIT, &error, timeop);
>>  	if (error < 0)
>>  		goto end;
>> =20
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 98bad1fb1bfb..f21df9360492 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1343,7 +1343,7 @@ static ssize_t tun_do_read(struct tun_struct *=
tun, struct tun_file *tfile,
>> =20
>>  	/* Read frames from queue */
>>  	skb =3D __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWA=
IT : 0,
>> -				  &peeked, &off, &err);
>> +				  &peeked, &off, &err, NULL);
>>  	if (skb) {
>>  		ret =3D tun_put_user(tun, tfile, skb, iv, len);
>>  		kfree_skb(skb);
>> @@ -1452,7 +1452,7 @@ static int tun_sendmsg(struct kiocb *iocb, str=
uct socket *sock,
>> =20
>>  static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
>>  		       struct msghdr *m, size_t total_len,
>> -		       int flags)
>> +		       int flags, long *timeop)
>>  {
>>  	struct tun_file *tfile =3D container_of(sock, struct tun_file, soc=
ket);
>>  	struct tun_struct *tun =3D __tun_get(tfile);
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 8dae2f724a35..6cd829e78ab6 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -602,7 +602,7 @@ static void handle_rx(struct vhost_net *net)
>>  		if (unlikely(headcount > UIO_MAXIOV)) {
>>  			msg.msg_iovlen =3D 1;
>>  			err =3D sock->ops->recvmsg(NULL, sock, &msg,
>> -						 1, MSG_DONTWAIT | MSG_TRUNC);
>> +						 1, MSG_DONTWAIT | MSG_TRUNC, NULL);
>>  			pr_debug("Discarded rx packet: len %zd\n", sock_len);
>>  			continue;
>>  		}
>> @@ -628,7 +628,7 @@ static void handle_rx(struct vhost_net *net)
>>  			copy_iovec_hdr(vq->iov, nvq->hdr, sock_hlen, in);
>>  		msg.msg_iovlen =3D in;
>>  		err =3D sock->ops->recvmsg(NULL, sock, &msg,
>> -					 sock_len, MSG_DONTWAIT | MSG_TRUNC);
>> +					 sock_len, MSG_DONTWAIT | MSG_TRUNC, NULL);
>>  		/* Userspace might have consumed the packet meanwhile:
>>  		 * it's not supposed to do this usually, but might be hard
>>  		 * to prevent. Discard data we got (if any) and keep going. */
>> diff --git a/include/linux/net.h b/include/linux/net.h
>> index 17d83393afcc..fcbbda434ff4 100644
>> --- a/include/linux/net.h
>> +++ b/include/linux/net.h
>> @@ -171,10 +171,13 @@ struct proto_ops {
>>  	 * returning uninitialized memory to user space.  The recvfrom
>>  	 * handlers can assume that msg.msg_name is either NULL or has
>>  	 * a minimum size of sizeof(struct sockaddr_storage).
>> +	 * timeop contains a per call timeout (as opposed as per socket,
>> +	 * used by recvmmsg, set it to NULL to disable it. It should retur=
n
>> +	 * the remaining time, if not NULL.
>>  	 */
>>  	int		(*recvmsg)   (struct kiocb *iocb, struct socket *sock,
>>  				      struct msghdr *m, size_t total_len,
>> -				      int flags);
>> +				      int flags, long *timeop);
>>  	int		(*mmap)	     (struct file *file, struct socket *sock,
>>  				      struct vm_area_struct * vma);
>>  	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
>> @@ -215,7 +218,7 @@ int sock_create_lite(int family, int type, int p=
roto, struct socket **res);
>>  void sock_release(struct socket *sock);
>>  int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t le=
n);
>>  int sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t si=
ze,
>> -		 int flags);
>> +		 int flags, long *timeop);
>>  struct file *sock_alloc_file(struct socket *sock, int flags, const =
char *dname);
>>  struct socket *sockfd_lookup(int fd, int *err);
>>  struct socket *sock_from_file(struct file *file, int *err);
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index ec89301ada41..37585fd26bd6 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -2513,9 +2513,9 @@ static inline void skb_frag_add_head(struct sk=
_buff *skb, struct sk_buff *frag)
>>  	for (iter =3D skb_shinfo(skb)->frag_list; iter; iter =3D iter->nex=
t)
>> =20
>>  struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags=
,
>> -				    int *peeked, int *off, int *err);
>> +				    int *peeked, int *off, int *err, long *timeop);
>>  struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, =
int noblock,
>> -				  int *err);
>> +				  int *err, long *timeop);
>>  unsigned int datagram_poll(struct file *file, struct socket *sock,
>>  			   struct poll_table_struct *wait);
>>  int skb_copy_datagram_iovec(const struct sk_buff *from, int offset,
>> diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
>> index 428277869400..6c007bd57f39 100644
>> --- a/include/net/af_vsock.h
>> +++ b/include/net/af_vsock.h
>> @@ -101,7 +101,7 @@ struct vsock_transport {
>>  	/* DGRAM. */
>>  	int (*dgram_bind)(struct vsock_sock *, struct sockaddr_vm *);
>>  	int (*dgram_dequeue)(struct kiocb *kiocb, struct vsock_sock *vsk,
>> -			     struct msghdr *msg, size_t len, int flags);
>> +			     struct msghdr *msg, size_t len, int flags, long *timeop);
>>  	int (*dgram_enqueue)(struct vsock_sock *, struct sockaddr_vm *,
>>  			     struct iovec *, size_t len);
>>  	bool (*dgram_allow)(u32 cid, u32 port);
>> diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetoo=
th/bluetooth.h
>> index 904777c1cd24..ee75e6875aab 100644
>> --- a/include/net/bluetooth/bluetooth.h
>> +++ b/include/net/bluetooth/bluetooth.h
>> @@ -246,9 +246,9 @@ void bt_sock_unregister(int proto);
>>  void bt_sock_link(struct bt_sock_list *l, struct sock *s);
>>  void bt_sock_unlink(struct bt_sock_list *l, struct sock *s);
>>  int  bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -				struct msghdr *msg, size_t len, int flags);
>> +				struct msghdr *msg, size_t len, int flags, long *timeop);
>>  int  bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock=
,
>> -			struct msghdr *msg, size_t len, int flags);
>> +			struct msghdr *msg, size_t len, int flags, long *timeop);
>>  uint bt_sock_poll(struct file *file, struct socket *sock, poll_tabl=
e *wait);
>>  int  bt_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned =
long arg);
>>  int  bt_sock_wait_state(struct sock *sk, int state, unsigned long t=
imeo);
>> diff --git a/include/net/inet_common.h b/include/net/inet_common.h
>> index fe7994c48b75..f80071949b98 100644
>> --- a/include/net/inet_common.h
>> +++ b/include/net/inet_common.h
>> @@ -26,7 +26,7 @@ int inet_sendmsg(struct kiocb *iocb, struct socket=
 *sock, struct msghdr *msg,
>>  ssize_t inet_sendpage(struct socket *sock, struct page *page, int o=
ffset,
>>  		      size_t size, int flags);
>>  int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct ms=
ghdr *msg,
>> -		 size_t size, int flags);
>> +		 size_t size, int flags, long *timeop);
>>  int inet_shutdown(struct socket *sock, int how);
>>  int inet_listen(struct socket *sock, int backlog);
>>  void inet_sock_destruct(struct sock *sk);
>> diff --git a/include/net/ping.h b/include/net/ping.h
>> index 026479b61a2d..c259ba72c811 100644
>> --- a/include/net/ping.h
>> +++ b/include/net/ping.h
>> @@ -76,7 +76,7 @@ int  ping_getfrag(void *from, char *to, int offset=
, int fraglen, int odd,
>>  		  struct sk_buff *);
>> =20
>>  int  ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghd=
r *msg,
>> -		  size_t len, int noblock, int flags, int *addr_len);
>> +		  size_t len, int noblock, int flags, int *addr_len, long *timeop=
);
>>  int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len=
,
>>  			 void *user_icmph, size_t icmph_len);
>>  int  ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct ms=
ghdr *msg,
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 156350745700..d2aad2123f53 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -961,7 +961,7 @@ struct proto {
>>  	int			(*recvmsg)(struct kiocb *iocb, struct sock *sk,
>>  					   struct msghdr *msg,
>>  					   size_t len, int noblock, int flags,
>> -					   int *addr_len);
>> +					   int *addr_len, long *timeop);
>>  	int			(*sendpage)(struct sock *sk, struct page *page,
>>  					int offset, size_t size, int flags);
>>  	int			(*bind)(struct sock *sk,
>> @@ -1593,7 +1593,7 @@ int sock_no_getsockopt(struct socket *, int , =
int, char __user *, int __user *);
>>  int sock_no_setsockopt(struct socket *, int, int, char __user *, un=
signed int);
>>  int sock_no_sendmsg(struct kiocb *, struct socket *, struct msghdr =
*, size_t);
>>  int sock_no_recvmsg(struct kiocb *, struct socket *, struct msghdr =
*, size_t,
>> -		    int);
>> +		    int, long *);
>>  int sock_no_mmap(struct file *file, struct socket *sock,
>>  		 struct vm_area_struct *vma);
>>  ssize_t sock_no_sendpage(struct socket *sock, struct page *page, in=
t offset,
>> @@ -1606,7 +1606,7 @@ ssize_t sock_no_sendpage(struct socket *sock, =
struct page *page, int offset,
>>  int sock_common_getsockopt(struct socket *sock, int level, int optn=
ame,
>>  				  char __user *optval, int __user *optlen);
>>  int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -			       struct msghdr *msg, size_t size, int flags);
>> +			       struct msghdr *msg, size_t size, int flags, long *timeop)=
;
>>  int sock_common_setsockopt(struct socket *sock, int level, int optn=
ame,
>>  				  char __user *optval, unsigned int optlen);
>>  int compat_sock_common_getsockopt(struct socket *sock, int level,
>> @@ -2104,6 +2104,11 @@ static inline long sock_rcvtimeo(const struct=
 sock *sk, bool noblock)
>>  	return noblock ? 0 : sk->sk_rcvtimeo;
>>  }
>> =20
>> +static inline long sock_rcvtimeop(const struct sock *sk, long *time=
op, bool noblock)
>> +{
>> +	return noblock ? 0 : (timeop ? *timeop : sk->sk_rcvtimeo);
>> +}
>> +
>>  static inline long sock_sndtimeo(const struct sock *sk, bool nobloc=
k)
>>  {
>>  	return noblock ? 0 : sk->sk_sndtimeo;
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 7286db80e8b8..ca560b38a4a1 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -437,7 +437,7 @@ int compat_tcp_setsockopt(struct sock *sk, int l=
evel, int optname,
>>  void tcp_set_keepalive(struct sock *sk, int val);
>>  void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req)=
;
>>  int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr =
*msg,
>> -		size_t len, int nonblock, int flags, int *addr_len);
>> +		size_t len, int nonblock, int flags, int *addr_len, long *timeop)=
;
>>  void tcp_parse_options(const struct sk_buff *skb,
>>  		       struct tcp_options_received *opt_rx,
>>  		       int estab, struct tcp_fastopen_cookie *foc);
>> diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
>> index bfcf6be1d665..3160f6af88b2 100644
>> --- a/net/appletalk/ddp.c
>> +++ b/net/appletalk/ddp.c
>> @@ -1729,7 +1729,7 @@ out:
>>  }
>> =20
>>  static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, s=
truct msghdr *msg,
>> -			 size_t size, int flags)
>> +			 size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct ddpehdr *ddp;
>> @@ -1739,7 +1739,7 @@ static int atalk_recvmsg(struct kiocb *iocb, s=
truct socket *sock, struct msghdr
>>  	struct sk_buff *skb;
>> =20
>>  	skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>> -						flags & MSG_DONTWAIT, &err);
>> +						flags & MSG_DONTWAIT, &err, timeop);
>>  	lock_sock(sk);
>> =20
>>  	if (!skb)
>> diff --git a/net/atm/common.c b/net/atm/common.c
>> index 7b491006eaf4..8def66eaed87 100644
>> --- a/net/atm/common.c
>> +++ b/net/atm/common.c
>> @@ -524,7 +524,7 @@ int vcc_connect(struct socket *sock, int itf, sh=
ort vpi, int vci)
>>  }
>> =20
>>  int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msg=
hdr *msg,
>> -		size_t size, int flags)
>> +		size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct atm_vcc *vcc;
>> @@ -544,7 +544,7 @@ int vcc_recvmsg(struct kiocb *iocb, struct socke=
t *sock, struct msghdr *msg,
>>  	    !test_bit(ATM_VF_READY, &vcc->flags))
>>  		return 0;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error)=
;
>> +	skb =3D skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error,=
 timeop);
>>  	if (!skb)
>>  		return error;
>> =20
>> diff --git a/net/atm/common.h b/net/atm/common.h
>> index cc3c2dae4d79..b370ffd78a39 100644
>> --- a/net/atm/common.h
>> +++ b/net/atm/common.h
>> @@ -14,7 +14,7 @@ int vcc_create(struct net *net, struct socket *soc=
k, int protocol, int family);
>>  int vcc_release(struct socket *sock);
>>  int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
>>  int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msg=
hdr *msg,
>> -		size_t size, int flags);
>> +		size_t size, int flags, long *timeop);
>>  int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msg=
hdr *m,
>>  		size_t total_len);
>>  unsigned int vcc_poll(struct file *file, struct socket *sock, poll_=
table *wait);
>> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
>> index c35c3f48fc0f..ee0411920216 100644
>> --- a/net/ax25/af_ax25.c
>> +++ b/net/ax25/af_ax25.c
>> @@ -1600,7 +1600,7 @@ out:
>>  }
>> =20
>>  static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -	struct msghdr *msg, size_t size, int flags)
>> +	struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct sk_buff *skb;
>> @@ -1619,7 +1619,7 @@ static int ax25_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
>> =20
>>  	/* Now we can treat all alike */
>>  	skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>> -				flags & MSG_DONTWAIT, &err);
>> +				flags & MSG_DONTWAIT, &err, timeop);
>>  	if (skb =3D=3D NULL)
>>  		goto out;
>> =20
>> diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetoo=
th.c
>> index 2021c481cdb6..4896bd954293 100644
>> --- a/net/bluetooth/af_bluetooth.c
>> +++ b/net/bluetooth/af_bluetooth.c
>> @@ -209,7 +209,7 @@ struct sock *bt_accept_dequeue(struct sock *pare=
nt, struct socket *newsock)
>>  EXPORT_SYMBOL(bt_accept_dequeue);
>> =20
>>  int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -				struct msghdr *msg, size_t len, int flags)
>> +				struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	int noblock =3D flags & MSG_DONTWAIT;
>>  	struct sock *sk =3D sock->sk;
>> @@ -222,7 +222,7 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct s=
ocket *sock,
>>  	if (flags & (MSG_OOB))
>>  		return -EOPNOTSUPP;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb) {
>>  		if (sk->sk_shutdown & RCV_SHUTDOWN)
>>  			return 0;
>> @@ -282,7 +282,7 @@ static long bt_sock_data_wait(struct sock *sk, l=
ong timeo)
>>  }
>> =20
>>  int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -			       struct msghdr *msg, size_t size, int flags)
>> +			       struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	int err =3D 0;
>> @@ -297,7 +297,7 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, s=
truct socket *sock,
>>  	lock_sock(sk);
>> =20
>>  	target =3D sock_rcvlowat(sk, flags & MSG_WAITALL, size);
>> -	timeo  =3D sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
>> +	timeo  =3D sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
>> =20
>>  	do {
>>  		struct sk_buff *skb;
>> @@ -381,6 +381,8 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, s=
truct socket *sock,
>>  	} while (size);
>> =20
>>  out:
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	release_sock(sk);
>>  	return copied ? : err;
>>  }
>> diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
>> index 80d25c150a65..71934e068bbf 100644
>> --- a/net/bluetooth/hci_sock.c
>> +++ b/net/bluetooth/hci_sock.c
>> @@ -829,7 +829,7 @@ static void hci_sock_cmsg(struct sock *sk, struc=
t msghdr *msg,
>>  }
>> =20
>>  static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock=
,
>> -			    struct msghdr *msg, size_t len, int flags)
>> +			    struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	int noblock =3D flags & MSG_DONTWAIT;
>>  	struct sock *sk =3D sock->sk;
>> @@ -844,7 +844,7 @@ static int hci_sock_recvmsg(struct kiocb *iocb, =
struct socket *sock,
>>  	if (sk->sk_state =3D=3D BT_CLOSED)
>>  		return 0;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		return err;
>> =20
>> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
>> index e1378693cc90..b4a91945bc0a 100644
>> --- a/net/bluetooth/l2cap_sock.c
>> +++ b/net/bluetooth/l2cap_sock.c
>> @@ -971,7 +971,7 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb=
, struct socket *sock,
>>  }
>> =20
>>  static int l2cap_sock_recvmsg(struct kiocb *iocb, struct socket *so=
ck,
>> -			      struct msghdr *msg, size_t len, int flags)
>> +			      struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
>> @@ -998,9 +998,9 @@ static int l2cap_sock_recvmsg(struct kiocb *iocb=
, struct socket *sock,
>>  	release_sock(sk);
>> =20
>>  	if (sock->type =3D=3D SOCK_STREAM)
>> -		err =3D bt_sock_stream_recvmsg(iocb, sock, msg, len, flags);
>> +		err =3D bt_sock_stream_recvmsg(iocb, sock, msg, len, flags, timeo=
p);
>>  	else
>> -		err =3D bt_sock_recvmsg(iocb, sock, msg, len, flags);
>> +		err =3D bt_sock_recvmsg(iocb, sock, msg, len, flags, timeop);
>> =20
>>  	if (pi->chan->mode !=3D L2CAP_MODE_ERTM)
>>  		return err;
>> diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock=
=2Ec
>> index c603a5eb4720..a3cbf8c4daf5 100644
>> --- a/net/bluetooth/rfcomm/sock.c
>> +++ b/net/bluetooth/rfcomm/sock.c
>> @@ -617,7 +617,7 @@ done:
>>  }
>> =20
>>  static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *s=
ock,
>> -			       struct msghdr *msg, size_t size, int flags)
>> +			       struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct rfcomm_dlc *d =3D rfcomm_pi(sk)->dlc;
>> @@ -628,7 +628,7 @@ static int rfcomm_sock_recvmsg(struct kiocb *ioc=
b, struct socket *sock,
>>  		return 0;
>>  	}
>> =20
>> -	len =3D bt_sock_stream_recvmsg(iocb, sock, msg, size, flags);
>> +	len =3D bt_sock_stream_recvmsg(iocb, sock, msg, size, flags, timeo=
p);
>> =20
>>  	lock_sock(sk);
>>  	if (!(flags & MSG_PEEK) && len > 0)
>> diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
>> index c06dbd3938e8..bfaa16bdc366 100644
>> --- a/net/bluetooth/sco.c
>> +++ b/net/bluetooth/sco.c
>> @@ -700,7 +700,7 @@ static void sco_conn_defer_accept(struct hci_con=
n *conn, u16 setting)
>>  }
>> =20
>>  static int sco_sock_recvmsg(struct kiocb *iocb, struct socket *sock=
,
>> -			    struct msghdr *msg, size_t len, int flags)
>> +			    struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct sco_pinfo *pi =3D sco_pi(sk);
>> @@ -718,7 +718,7 @@ static int sco_sock_recvmsg(struct kiocb *iocb, =
struct socket *sock,
>> =20
>>  	release_sock(sk);
>> =20
>> -	return bt_sock_recvmsg(iocb, sock, msg, len, flags);
>> +	return bt_sock_recvmsg(iocb, sock, msg, len, flags, timeop);
>>  }
>> =20
>>  static int sco_sock_setsockopt(struct socket *sock, int level, int =
optname, char __user *optval, unsigned int optlen)
>> diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
>> index e8437094d15f..069eb2ffde29 100644
>> --- a/net/caif/caif_socket.c
>> +++ b/net/caif/caif_socket.c
>> @@ -272,7 +272,7 @@ static void caif_check_flow_release(struct sock =
*sk)
>>   * changed locking, address handling and added MSG_TRUNC.
>>   */
>>  static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *s=
ock,
>> -			       struct msghdr *m, size_t len, int flags)
>> +			       struct msghdr *m, size_t len, int flags, long *timeop)
>> =20
>>  {
>>  	struct sock *sk =3D sock->sk;
>> @@ -284,7 +284,7 @@ static int caif_seqpkt_recvmsg(struct kiocb *ioc=
b, struct socket *sock,
>>  	if (m->msg_flags&MSG_OOB)
>>  		goto read_error;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, 0 , &ret);
>> +	skb =3D skb_recv_datagram(sk, flags, 0 , &ret, timeop);
>>  	if (!skb)
>>  		goto read_error;
>>  	copylen =3D skb->len;
>> @@ -345,7 +345,7 @@ static long caif_stream_data_wait(struct sock *s=
k, long timeo)
>>   */
>>  static int caif_stream_recvmsg(struct kiocb *iocb, struct socket *s=
ock,
>>  			       struct msghdr *msg, size_t size,
>> -			       int flags)
>> +			       int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	int copied =3D 0;
>> @@ -367,7 +367,7 @@ static int caif_stream_recvmsg(struct kiocb *ioc=
b, struct socket *sock,
>> =20
>>  	caif_read_lock(sk);
>>  	target =3D sock_rcvlowat(sk, flags&MSG_WAITALL, size);
>> -	timeo =3D sock_rcvtimeo(sk, flags&MSG_DONTWAIT);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, flags&MSG_DONTWAIT);
>> =20
>>  	do {
>>  		int chunk;
>> @@ -450,6 +450,8 @@ unlock:
>>  	caif_read_unlock(sk);
>> =20
>>  out:
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return copied ? : err;
>>  }
>> =20
>> diff --git a/net/can/bcm.c b/net/can/bcm.c
>> index dcb75c0e66c1..dc12c80ec5cd 100644
>> --- a/net/can/bcm.c
>> +++ b/net/can/bcm.c
>> @@ -1541,7 +1541,7 @@ static int bcm_connect(struct socket *sock, st=
ruct sockaddr *uaddr, int len,
>>  }
>> =20
>>  static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -		       struct msghdr *msg, size_t size, int flags)
>> +		       struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct sk_buff *skb;
>> @@ -1551,7 +1551,7 @@ static int bcm_recvmsg(struct kiocb *iocb, str=
uct socket *sock,
>> =20
>>  	noblock =3D  flags & MSG_DONTWAIT;
>>  	flags   &=3D ~MSG_DONTWAIT;
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &error);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &error, timeop);
>>  	if (!skb)
>>  		return error;
>> =20
>> diff --git a/net/can/raw.c b/net/can/raw.c
>> index 081e81fd017f..0a4aa9d98e5e 100644
>> --- a/net/can/raw.c
>> +++ b/net/can/raw.c
>> @@ -731,7 +731,7 @@ send_failed:
>>  }
>> =20
>>  static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -		       struct msghdr *msg, size_t size, int flags)
>> +		       struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct sk_buff *skb;
>> @@ -741,7 +741,7 @@ static int raw_recvmsg(struct kiocb *iocb, struc=
t socket *sock,
>>  	noblock =3D  flags & MSG_DONTWAIT;
>>  	flags   &=3D ~MSG_DONTWAIT;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		return err;
>> =20
>> diff --git a/net/core/datagram.c b/net/core/datagram.c
>> index 488dd1a825c0..856e18c586c6 100644
>> --- a/net/core/datagram.c
>> +++ b/net/core/datagram.c
>> @@ -138,6 +138,9 @@ out_noerr:
>>   *	@off: an offset in bytes to peek skb from. Returns an offset
>>   *	      within an skb where data actually starts
>>   *	@err: error code returned
>> + *	@timeop: per call timeout (as opposed as per socket via SO_RCVTI=
MEO),
>> + *		 will return the remaining time, used in recvmmsg, ignored
>> + *		 if set to NULL.
>>   *
>>   *	Get a datagram skbuff, understands the peeking, nonblocking wake=
ups
>>   *	and possible races. This replaces identical code in packet, raw =
and
>> @@ -162,7 +165,7 @@ out_noerr:
>>   *	the standard around please.
>>   */
>>  struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int f=
lags,
>> -				    int *peeked, int *off, int *err)
>> +				    int *peeked, int *off, int *err, long *timeop)
>>  {
>>  	struct sk_buff *skb, *last;
>>  	long timeo;
>> @@ -174,7 +177,7 @@ struct sk_buff *__skb_recv_datagram(struct sock =
*sk, unsigned int flags,
>>  	if (error)
>>  		goto no_packet;
>> =20
>> -	timeo =3D sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
>> =20
>>  	do {
>>  		/* Again only user level code calls this function, so nothing
>> @@ -205,6 +208,8 @@ struct sk_buff *__skb_recv_datagram(struct sock =
*sk, unsigned int flags,
>> =20
>>  			spin_unlock_irqrestore(&queue->lock, cpu_flags);
>>  			*off =3D _off;
>> +			if (timeop)
>> +				*timeop =3D timeo;
>>  			return skb;
>>  		}
>>  		spin_unlock_irqrestore(&queue->lock, cpu_flags);
>> @@ -219,22 +224,24 @@ struct sk_buff *__skb_recv_datagram(struct soc=
k *sk, unsigned int flags,
>>  			goto no_packet;
>> =20
>>  	} while (!wait_for_more_packets(sk, err, &timeo, last));
>> -
>> +out:
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return NULL;
>> =20
>>  no_packet:
>>  	*err =3D error;
>> -	return NULL;
>> +	goto out;
>>  }
>>  EXPORT_SYMBOL(__skb_recv_datagram);
>> =20
>>  struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned int fla=
gs,
>> -				  int noblock, int *err)
>> +				  int noblock, int *err, long *timeop)
>>  {
>>  	int peeked, off =3D 0;
>> =20
>>  	return __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0=
),
>> -				   &peeked, &off, err);
>> +				   &peeked, &off, err, timeop);
>>  }
>>  EXPORT_SYMBOL(skb_recv_datagram);
>> =20
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 026e01f70274..b462e38785af 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -2191,7 +2191,7 @@ int sock_no_sendmsg(struct kiocb *iocb, struct=
 socket *sock, struct msghdr *m,
>>  EXPORT_SYMBOL(sock_no_sendmsg);
>> =20
>>  int sock_no_recvmsg(struct kiocb *iocb, struct socket *sock, struct=
 msghdr *m,
>> -		    size_t len, int flags)
>> +		    size_t len, int flags, long *timeop)
>>  {
>>  	return -EOPNOTSUPP;
>>  }
>> @@ -2577,14 +2577,14 @@ EXPORT_SYMBOL(compat_sock_common_getsockopt)=
;
>>  #endif
>> =20
>>  int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -			struct msghdr *msg, size_t size, int flags)
>> +			struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	int addr_len =3D 0;
>>  	int err;
>> =20
>>  	err =3D sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONT=
WAIT,
>> -				   flags & ~MSG_DONTWAIT, &addr_len);
>> +				   flags & ~MSG_DONTWAIT, &addr_len, timeop);
>>  	if (err >=3D 0)
>>  		msg->msg_namelen =3D addr_len;
>>  	return err;
>> diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
>> index c67816647cce..fbf4cc113ffe 100644
>> --- a/net/dccp/dccp.h
>> +++ b/net/dccp/dccp.h
>> @@ -314,7 +314,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock=
 *sk, struct msghdr *msg,
>>  		 size_t size);
>>  int dccp_recvmsg(struct kiocb *iocb, struct sock *sk,
>>  		 struct msghdr *msg, size_t len, int nonblock, int flags,
>> -		 int *addr_len);
>> +		 int *addr_len, long *timeop);
>>  void dccp_shutdown(struct sock *sk, int how);
>>  int inet_dccp_listen(struct socket *sock, int backlog);
>>  unsigned int dccp_poll(struct file *file, struct socket *sock,
>> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
>> index de2c1e719305..92ae3d37c7f0 100644
>> --- a/net/dccp/proto.c
>> +++ b/net/dccp/proto.c
>> @@ -808,7 +808,7 @@ out_discard:
>>  EXPORT_SYMBOL_GPL(dccp_sendmsg);
>> =20
>>  int dccp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr=
 *msg,
>> -		 size_t len, int nonblock, int flags, int *addr_len)
>> +		 size_t len, int nonblock, int flags, int *addr_len, long *timeop=
)
>>  {
>>  	const struct dccp_hdr *dh;
>>  	long timeo;
>> @@ -820,7 +820,7 @@ int dccp_recvmsg(struct kiocb *iocb, struct sock=
 *sk, struct msghdr *msg,
>>  		goto out;
>>  	}
>> =20
>> -	timeo =3D sock_rcvtimeo(sk, nonblock);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, nonblock);
>> =20
>>  	do {
>>  		struct sk_buff *skb =3D skb_peek(&sk->sk_receive_queue);
>> @@ -910,6 +910,8 @@ verify_sock_status:
>>  	} while (1);
>>  out:
>>  	release_sock(sk);
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return len;
>>  }
>> =20
>> diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
>> index ae011b46c071..86dfcbe505de 100644
>> --- a/net/decnet/af_decnet.c
>> +++ b/net/decnet/af_decnet.c
>> @@ -1669,7 +1669,7 @@ static int dn_data_ready(struct sock *sk, stru=
ct sk_buff_head *q, int flags, int
>> =20
>> =20
>>  static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -	struct msghdr *msg, size_t size, int flags)
>> +	struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct dn_scp *scp =3D DN_SK(sk);
>> @@ -1680,7 +1680,7 @@ static int dn_recvmsg(struct kiocb *iocb, stru=
ct socket *sock,
>>  	struct sk_buff *skb, *n;
>>  	struct dn_skb_cb *cb =3D NULL;
>>  	unsigned char eor =3D 0;
>> -	long timeo =3D sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
>> +	long timeo =3D sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
>> =20
>>  	lock_sock(sk);
>> =20
>> @@ -1814,7 +1814,8 @@ out:
>>  	}
>> =20
>>  	release_sock(sk);
>> -
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return rv;
>>  }
>> =20
>> diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
>> index 4f0ed8780194..dd7de8959d07 100644
>> --- a/net/ieee802154/dgram.c
>> +++ b/net/ieee802154/dgram.c
>> @@ -305,14 +305,14 @@ out:
>> =20
>>  static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
>>  		struct msghdr *msg, size_t len, int noblock, int flags,
>> -		int *addr_len)
>> +		int *addr_len, long *timeop)
>>  {
>>  	size_t copied =3D 0;
>>  	int err =3D -EOPNOTSUPP;
>>  	struct sk_buff *skb;
>>  	DECLARE_SOCKADDR(struct sockaddr_ieee802154 *, saddr, msg->msg_nam=
e);
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
>> index 74d54fae33d7..0303aa66a9e2 100644
>> --- a/net/ieee802154/raw.c
>> +++ b/net/ieee802154/raw.c
>> @@ -179,13 +179,13 @@ out:
>>  }
>> =20
>>  static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct =
msghdr *msg,
>> -		       size_t len, int noblock, int flags, int *addr_len)
>> +		       size_t len, int noblock, int flags, int *addr_len, long *t=
imeop)
>>  {
>>  	size_t copied =3D 0;
>>  	int err =3D -EOPNOTSUPP;
>>  	struct sk_buff *skb;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index d156b3c5f363..69356a067dbf 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -757,7 +757,7 @@ ssize_t inet_sendpage(struct socket *sock, struc=
t page *page, int offset,
>>  EXPORT_SYMBOL(inet_sendpage);
>> =20
>>  int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct ms=
ghdr *msg,
>> -		 size_t size, int flags)
>> +		 size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	int addr_len =3D 0;
>> @@ -766,7 +766,7 @@ int inet_recvmsg(struct kiocb *iocb, struct sock=
et *sock, struct msghdr *msg,
>>  	sock_rps_record_flow(sk);
>> =20
>>  	err =3D sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONT=
WAIT,
>> -				   flags & ~MSG_DONTWAIT, &addr_len);
>> +				   flags & ~MSG_DONTWAIT, &addr_len, timeop);
>>  	if (err >=3D 0)
>>  		msg->msg_namelen =3D addr_len;
>>  	return err;
>> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
>> index 044a0ddf6a79..791be60b38f1 100644
>> --- a/net/ipv4/ping.c
>> +++ b/net/ipv4/ping.c
>> @@ -840,7 +840,7 @@ do_confirm:
>>  }
>> =20
>>  int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr=
 *msg,
>> -		 size_t len, int noblock, int flags, int *addr_len)
>> +		 size_t len, int noblock, int flags, int *addr_len, long *timeop)
>>  {
>>  	struct inet_sock *isk =3D inet_sk(sk);
>>  	int family =3D sk->sk_family;
>> @@ -864,7 +864,7 @@ int ping_recvmsg(struct kiocb *iocb, struct sock=
 *sk, struct msghdr *msg,
>>  		}
>>  	}
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
>> index 2c65160565e1..bf4fc70229e7 100644
>> --- a/net/ipv4/raw.c
>> +++ b/net/ipv4/raw.c
>> @@ -685,7 +685,7 @@ out:	return ret;
>>   */
>> =20
>>  static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct =
msghdr *msg,
>> -		       size_t len, int noblock, int flags, int *addr_len)
>> +		       size_t len, int noblock, int flags, int *addr_len, long *t=
imeop)
>>  {
>>  	struct inet_sock *inet =3D inet_sk(sk);
>>  	size_t copied =3D 0;
>> @@ -701,7 +701,7 @@ static int raw_recvmsg(struct kiocb *iocb, struc=
t sock *sk, struct msghdr *msg,
>>  		goto out;
>>  	}
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index 9d2118e5fbc7..0572060f83aa 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -1602,7 +1602,7 @@ EXPORT_SYMBOL(tcp_read_sock);
>>   */
>> =20
>>  int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr =
*msg,
>> -		size_t len, int nonblock, int flags, int *addr_len)
>> +		size_t len, int nonblock, int flags, int *addr_len, long *timeop)
>>  {
>>  	struct tcp_sock *tp =3D tcp_sk(sk);
>>  	int copied =3D 0;
>> @@ -1627,7 +1627,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct soc=
k *sk, struct msghdr *msg,
>>  	if (sk->sk_state =3D=3D TCP_LISTEN)
>>  		goto out;
>> =20
>> -	timeo =3D sock_rcvtimeo(sk, nonblock);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, nonblock);
>> =20
>>  	/* Urgent data needs to be handled specially. */
>>  	if (flags & MSG_OOB)
>> @@ -1994,20 +1994,18 @@ skip_copy:
>> =20
>>  	/* Clean up data we have read: This will do ACK frames. */
>>  	tcp_cleanup_rbuf(sk, copied);
>> -
>> -	release_sock(sk);
>> -	return copied;
>> -
>>  out:
>>  	release_sock(sk);
>> -	return err;
>> +	if (timeop)
>> +		*timeop =3D timeo;
>> +	return copied;
>> =20
>>  recv_urg:
>> -	err =3D tcp_recv_urg(sk, msg, len, flags);
>> +	copied =3D tcp_recv_urg(sk, msg, len, flags);
>>  	goto out;
>> =20
>>  recv_sndq:
>> -	err =3D tcp_peek_sndq(sk, msg, len);
>> +	copied =3D tcp_peek_sndq(sk, msg, len);
>>  	goto out;
>>  }
>>  EXPORT_SYMBOL(tcp_recvmsg);
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index 7d5a8661df76..0c77df4c3523 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -1262,7 +1262,7 @@ EXPORT_SYMBOL(udp_ioctl);
>>   */
>> =20
>>  int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr =
*msg,
>> -		size_t len, int noblock, int flags, int *addr_len)
>> +		size_t len, int noblock, int flags, int *addr_len, long *timeop)
>>  {
>>  	struct inet_sock *inet =3D inet_sk(sk);
>>  	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
>> @@ -1278,7 +1278,7 @@ int udp_recvmsg(struct kiocb *iocb, struct soc=
k *sk, struct msghdr *msg,
>> =20
>>  try_again:
>>  	skb =3D __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : =
0),
>> -				  &peeked, &off, &err);
>> +				  &peeked, &off, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
>> index f3c27899f62b..a39aa9996b72 100644
>> --- a/net/ipv4/udp_impl.h
>> +++ b/net/ipv4/udp_impl.h
>> @@ -22,7 +22,7 @@ int compat_udp_getsockopt(struct sock *sk, int lev=
el, int optname,
>>  			  char __user *optval, int __user *optlen);
>>  #endif
>>  int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr =
*msg,
>> -		size_t len, int noblock, int flags, int *addr_len);
>> +		size_t len, int noblock, int flags, int *addr_len, long *timeop);
>>  int udp_sendpage(struct sock *sk, struct page *page, int offset, si=
ze_t size,
>>  		 int flags);
>>  int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
>> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
>> index b2dc60b0c764..1d267f89eb71 100644
>> --- a/net/ipv6/raw.c
>> +++ b/net/ipv6/raw.c
>> @@ -458,7 +458,7 @@ int rawv6_rcv(struct sock *sk, struct sk_buff *s=
kb)
>> =20
>>  static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
>>  		  struct msghdr *msg, size_t len,
>> -		  int noblock, int flags, int *addr_len)
>> +		  int noblock, int flags, int *addr_len, long *timeop)
>>  {
>>  	struct ipv6_pinfo *np =3D inet6_sk(sk);
>>  	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
>> @@ -475,7 +475,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, str=
uct sock *sk,
>>  	if (np->rxpmtu && np->rxopt.bits.rxpmtu)
>>  		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
>> index 7092ff78fd84..6963babf2dff 100644
>> --- a/net/ipv6/udp.c
>> +++ b/net/ipv6/udp.c
>> @@ -380,7 +380,7 @@ EXPORT_SYMBOL_GPL(udp6_lib_lookup);
>> =20
>>  int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
>>  		  struct msghdr *msg, size_t len,
>> -		  int noblock, int flags, int *addr_len)
>> +		  int noblock, int flags, int *addr_len, long *timeop)
>>  {
>>  	struct ipv6_pinfo *np =3D inet6_sk(sk);
>>  	struct inet_sock *inet =3D inet_sk(sk);
>> @@ -400,7 +400,7 @@ int udpv6_recvmsg(struct kiocb *iocb, struct soc=
k *sk,
>> =20
>>  try_again:
>>  	skb =3D __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : =
0),
>> -				  &peeked, &off, &err);
>> +				  &peeked, &off, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
>> index c779c3c90b9d..cd414d719977 100644
>> --- a/net/ipv6/udp_impl.h
>> +++ b/net/ipv6/udp_impl.h
>> @@ -26,7 +26,7 @@ int compat_udpv6_getsockopt(struct sock *sk, int l=
evel, int optname,
>>  int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghd=
r *msg,
>>  		  size_t len);
>>  int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghd=
r *msg,
>> -		  size_t len, int noblock, int flags, int *addr_len);
>> +		  size_t len, int noblock, int flags, int *addr_len, long *timeop=
);
>>  int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
>>  void udpv6_destroy_sock(struct sock *sk);
>> =20
>> diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
>> index 91729b807c7d..4964c1e0ab03 100644
>> --- a/net/ipx/af_ipx.c
>> +++ b/net/ipx/af_ipx.c
>> @@ -1756,7 +1756,7 @@ out:
>> =20
>> =20
>>  static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -		struct msghdr *msg, size_t size, int flags)
>> +		struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct ipx_sock *ipxs =3D ipx_sk(sk);
>> @@ -1791,7 +1791,7 @@ static int ipx_recvmsg(struct kiocb *iocb, str=
uct socket *sock,
>>  		goto out;
>> =20
>>  	skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>> -				flags & MSG_DONTWAIT, &rc);
>> +				flags & MSG_DONTWAIT, &rc, timeop);
>>  	if (!skb) {
>>  		if (rc =3D=3D -EAGAIN && (sk->sk_shutdown & RCV_SHUTDOWN))
>>  			rc =3D 0;
>> diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
>> index 54747c25c86c..0991da69f39d 100644
>> --- a/net/irda/af_irda.c
>> +++ b/net/irda/af_irda.c
>> @@ -1373,7 +1373,7 @@ out:
>>   *    after being read, regardless of how much the user actually re=
ad
>>   */
>>  static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *so=
ck,
>> -			      struct msghdr *msg, size_t size, int flags)
>> +			      struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct irda_sock *self =3D irda_sk(sk);
>> @@ -1384,7 +1384,7 @@ static int irda_recvmsg_dgram(struct kiocb *io=
cb, struct socket *sock,
>>  	IRDA_DEBUG(4, "%s()\n", __func__);
>> =20
>>  	skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>> -				flags & MSG_DONTWAIT, &err);
>> +				flags & MSG_DONTWAIT, &err, timeop);
>>  	if (!skb)
>>  		return err;
>> =20
>> @@ -1422,7 +1422,7 @@ static int irda_recvmsg_dgram(struct kiocb *io=
cb, struct socket *sock,
>>   * Function irda_recvmsg_stream (iocb, sock, msg, size, flags)
>>   */
>>  static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *s=
ock,
>> -			       struct msghdr *msg, size_t size, int flags)
>> +			       struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct irda_sock *self =3D irda_sk(sk);
>> @@ -1445,7 +1445,7 @@ static int irda_recvmsg_stream(struct kiocb *i=
ocb, struct socket *sock,
>> =20
>>  	err =3D 0;
>>  	target =3D sock_rcvlowat(sk, flags & MSG_WAITALL, size);
>> -	timeo =3D sock_rcvtimeo(sk, noblock);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, noblock);
>> =20
>>  	do {
>>  		int chunk;
>> @@ -1480,8 +1480,10 @@ static int irda_recvmsg_stream(struct kiocb *=
iocb, struct socket *sock,
>> =20
>>  			finish_wait(sk_sleep(sk), &wait);
>> =20
>> -			if (err)
>> -				return err;
>> +			if (err) {
>> +				copied =3D err;
>> +				break;
>> +			}
>>  			if (sk->sk_shutdown & RCV_SHUTDOWN)
>>  				break;
>> =20
>> @@ -1534,6 +1536,8 @@ static int irda_recvmsg_stream(struct kiocb *i=
ocb, struct socket *sock,
>>  		}
>>  	}
>> =20
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return copied;
>>  }
>> =20
>> diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
>> index 7a95fa4a3de1..3aebb4ffae54 100644
>> --- a/net/iucv/af_iucv.c
>> +++ b/net/iucv/af_iucv.c
>> @@ -1321,7 +1321,7 @@ static void iucv_process_message_q(struct sock=
 *sk)
>>  }
>> =20
>>  static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *soc=
k,
>> -			     struct msghdr *msg, size_t len, int flags)
>> +			     struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	int noblock =3D flags & MSG_DONTWAIT;
>>  	struct sock *sk =3D sock->sk;
>> @@ -1342,7 +1342,7 @@ static int iucv_sock_recvmsg(struct kiocb *ioc=
b, struct socket *sock,
>> =20
>>  	/* receive/dequeue next skb:
>>  	 * the function understands MSG_PEEK and, thus, does not dequeue s=
kb */
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb) {
>>  		if (sk->sk_shutdown & RCV_SHUTDOWN)
>>  			return 0;
>> diff --git a/net/key/af_key.c b/net/key/af_key.c
>> index ba2a2f95911c..27a2119bb905 100644
>> --- a/net/key/af_key.c
>> +++ b/net/key/af_key.c
>> @@ -3635,7 +3635,7 @@ out:
>> =20
>>  static int pfkey_recvmsg(struct kiocb *kiocb,
>>  			 struct socket *sock, struct msghdr *msg, size_t len,
>> -			 int flags)
>> +			 int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct pfkey_sock *pfk =3D pfkey_sk(sk);
>> @@ -3646,7 +3646,7 @@ static int pfkey_recvmsg(struct kiocb *kiocb,
>>  	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
>>  		goto out;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err, t=
imeop);
>>  	if (skb =3D=3D NULL)
>>  		goto out;
>> =20
>> diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
>> index 369a9822488c..4347233855cb 100644
>> --- a/net/l2tp/l2tp_ip.c
>> +++ b/net/l2tp/l2tp_ip.c
>> @@ -507,7 +507,7 @@ no_route:
>>  }
>> =20
>>  static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, str=
uct msghdr *msg,
>> -			   size_t len, int noblock, int flags, int *addr_len)
>> +			   size_t len, int noblock, int flags, int *addr_len, long *time=
op)
>>  {
>>  	struct inet_sock *inet =3D inet_sk(sk);
>>  	size_t copied =3D 0;
>> @@ -518,7 +518,7 @@ static int l2tp_ip_recvmsg(struct kiocb *iocb, s=
truct sock *sk, struct msghdr *m
>>  	if (flags & MSG_OOB)
>>  		goto out;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
>> index f3f98a156cee..6c839ba9d299 100644
>> --- a/net/l2tp/l2tp_ip6.c
>> +++ b/net/l2tp/l2tp_ip6.c
>> @@ -645,7 +645,7 @@ do_confirm:
>> =20
>>  static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
>>  			    struct msghdr *msg, size_t len, int noblock,
>> -			    int flags, int *addr_len)
>> +			    int flags, int *addr_len, long *timeop)
>>  {
>>  	struct ipv6_pinfo *np =3D inet6_sk(sk);
>>  	DECLARE_SOCKADDR(struct sockaddr_l2tpip6 *, lsa, msg->msg_name);
>> @@ -662,7 +662,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, =
struct sock *sk,
>>  	if (flags & MSG_ERRQUEUE)
>>  		return ipv6_recv_error(sk, msg, len, addr_len);
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
>> index 13752d96275e..88558464319b 100644
>> --- a/net/l2tp/l2tp_ppp.c
>> +++ b/net/l2tp/l2tp_ppp.c
>> @@ -187,7 +187,7 @@ static int pppol2tp_recv_payload_hook(struct sk_=
buff *skb)
>>   */
>>  static int pppol2tp_recvmsg(struct kiocb *iocb, struct socket *sock=
,
>>  			    struct msghdr *msg, size_t len,
>> -			    int flags)
>> +			    int flags, long *timeop)
>>  {
>>  	int err;
>>  	struct sk_buff *skb;
>> @@ -199,7 +199,7 @@ static int pppol2tp_recvmsg(struct kiocb *iocb, =
struct socket *sock,
>> =20
>>  	err =3D 0;
>>  	skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>> -				flags & MSG_DONTWAIT, &err);
>> +				flags & MSG_DONTWAIT, &err, timeop);
>>  	if (!skb)
>>  		goto end;
>> =20
>> diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
>> index 0080d2b0a8ae..b5edf838f9fa 100644
>> --- a/net/llc/af_llc.c
>> +++ b/net/llc/af_llc.c
>> @@ -705,7 +705,7 @@ out:
>>   *	Returns non-negative upon success, negative otherwise.
>>   */
>>  static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -			  struct msghdr *msg, size_t len, int flags)
>> +			  struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	DECLARE_SOCKADDR(struct sockaddr_llc *, uaddr, msg->msg_name);
>>  	const int nonblock =3D flags & MSG_DONTWAIT;
>> @@ -725,7 +725,7 @@ static int llc_ui_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
>>  	if (unlikely(sk->sk_type =3D=3D SOCK_STREAM && sk->sk_state =3D=3D=
 TCP_LISTEN))
>>  		goto out;
>> =20
>> -	timeo =3D sock_rcvtimeo(sk, nonblock);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, nonblock);
>> =20
>>  	seq =3D &llc->copied_seq;
>>  	if (flags & MSG_PEEK) {
>> @@ -851,6 +851,8 @@ static int llc_ui_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
>> =20
>>  out:
>>  	release_sock(sk);
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return copied;
>>  copy_uaddr:
>>  	if (uaddr !=3D NULL && skb !=3D NULL) {
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index e6fac7e3db52..8d661b0b2ca3 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -2404,7 +2404,7 @@ out:
>> =20
>>  static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock=
,
>>  			   struct msghdr *msg, size_t len,
>> -			   int flags)
>> +			   int flags, long *timeop)
>>  {
>>  	struct sock_iocb *siocb =3D kiocb_to_siocb(kiocb);
>>  	struct scm_cookie scm;
>> @@ -2420,7 +2420,7 @@ static int netlink_recvmsg(struct kiocb *kiocb=
, struct socket *sock,
>> =20
>>  	copied =3D 0;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (skb =3D=3D NULL)
>>  		goto out;
>> =20
>> diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
>> index ede50d197e10..4a9078e2bf7a 100644
>> --- a/net/netrom/af_netrom.c
>> +++ b/net/netrom/af_netrom.c
>> @@ -1134,7 +1134,7 @@ out:
>>  }
>> =20
>>  static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -		      struct msghdr *msg, size_t size, int flags)
>> +		      struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	DECLARE_SOCKADDR(struct sockaddr_ax25 *, sax, msg->msg_name);
>> @@ -1154,7 +1154,7 @@ static int nr_recvmsg(struct kiocb *iocb, stru=
ct socket *sock,
>>  	}
>> =20
>>  	/* Now we can treat all alike */
>> -	if ((skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & =
MSG_DONTWAIT, &er)) =3D=3D NULL) {
>> +	if ((skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & =
MSG_DONTWAIT, &er, timeop)) =3D=3D NULL) {
>>  		release_sock(sk);
>>  		return er;
>>  	}
>> diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
>> index 51f077a92fa9..0b233d1f1a57 100644
>> --- a/net/nfc/llcp_sock.c
>> +++ b/net/nfc/llcp_sock.c
>> @@ -794,7 +794,7 @@ static int llcp_sock_sendmsg(struct kiocb *iocb,=
 struct socket *sock,
>>  }
>> =20
>>  static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *soc=
k,
>> -			     struct msghdr *msg, size_t len, int flags)
>> +			     struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	int noblock =3D flags & MSG_DONTWAIT;
>>  	struct sock *sk =3D sock->sk;
>> @@ -817,7 +817,7 @@ static int llcp_sock_recvmsg(struct kiocb *iocb,=
 struct socket *sock,
>>  	if (flags & (MSG_OOB))
>>  		return -EOPNOTSUPP;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb) {
>>  		pr_err("Recv datagram failed state %d %d %d",
>>  		       sk->sk_state, err, sock_error(sk));
>> diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
>> index 11c3544ea546..ab84d8740fe4 100644
>> --- a/net/nfc/rawsock.c
>> +++ b/net/nfc/rawsock.c
>> @@ -249,7 +249,7 @@ static int rawsock_sendmsg(struct kiocb *iocb, s=
truct socket *sock,
>>  }
>> =20
>>  static int rawsock_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -			   struct msghdr *msg, size_t len, int flags)
>> +			   struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	int noblock =3D flags & MSG_DONTWAIT;
>>  	struct sock *sk =3D sock->sk;
>> @@ -259,7 +259,7 @@ static int rawsock_recvmsg(struct kiocb *iocb, s=
truct socket *sock,
>> =20
>>  	pr_debug("sock=3D%p sk=3D%p len=3D%zu flags=3D%d\n", sock, sk, len=
, flags);
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &rc);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &rc, timeop);
>>  	if (!skb)
>>  		return rc;
>> =20
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index b85c67ccb797..f56d816340e2 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -2852,7 +2852,7 @@ out:
>>   */
>> =20
>>  static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -			  struct msghdr *msg, size_t len, int flags)
>> +			  struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct sk_buff *skb;
>> @@ -2884,7 +2884,7 @@ static int packet_recvmsg(struct kiocb *iocb, =
struct socket *sock,
>>  	 *	but then it will block.
>>  	 */
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err, t=
imeop);
>> =20
>>  	/*
>>  	 *	An error occurred so return it. Because skb_recv_datagram()
>> diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
>> index 290352c0e6b4..77eff48eeb83 100644
>> --- a/net/phonet/datagram.c
>> +++ b/net/phonet/datagram.c
>> @@ -127,7 +127,7 @@ static int pn_sendmsg(struct kiocb *iocb, struct=
 sock *sk,
>> =20
>>  static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
>>  			struct msghdr *msg, size_t len, int noblock,
>> -			int flags, int *addr_len)
>> +			int flags, int *addr_len, long *timeop)
>>  {
>>  	struct sk_buff *skb =3D NULL;
>>  	struct sockaddr_pn sa;
>> @@ -138,7 +138,7 @@ static int pn_recvmsg(struct kiocb *iocb, struct=
 sock *sk,
>>  			MSG_CMSG_COMPAT))
>>  		goto out_nofree;
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &rval);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &rval, timeop);
>>  	if (skb =3D=3D NULL)
>>  		goto out_nofree;
>> =20
>> diff --git a/net/phonet/pep.c b/net/phonet/pep.c
>> index 70a547ea5177..c5832e1958f8 100644
>> --- a/net/phonet/pep.c
>> +++ b/net/phonet/pep.c
>> @@ -783,7 +783,7 @@ static struct sock *pep_sock_accept(struct sock =
*sk, int flags, int *errp)
>>  	u8 pipe_handle, enabled, n_sb;
>>  	u8 aligned =3D 0;
>> =20
>> -	skb =3D skb_recv_datagram(sk, 0, flags & O_NONBLOCK, errp);
>> +	skb =3D skb_recv_datagram(sk, 0, flags & O_NONBLOCK, errp, NULL);
>>  	if (!skb)
>>  		return NULL;
>> =20
>> @@ -1248,7 +1248,7 @@ struct sk_buff *pep_read(struct sock *sk)
>> =20
>>  static int pep_recvmsg(struct kiocb *iocb, struct sock *sk,
>>  			struct msghdr *msg, size_t len, int noblock,
>> -			int flags, int *addr_len)
>> +			int flags, int *addr_len, long *timeop)
>>  {
>>  	struct sk_buff *skb;
>>  	int err;
>> @@ -1277,7 +1277,7 @@ static int pep_recvmsg(struct kiocb *iocb, str=
uct sock *sk,
>>  			return -EINVAL;
>>  	}
>> =20
>> -	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	lock_sock(sk);
>>  	if (skb =3D=3D NULL) {
>>  		if (err =3D=3D -ENOTCONN && sk->sk_state =3D=3D TCP_CLOSE_WAIT)
>> diff --git a/net/rds/rds.h b/net/rds/rds.h
>> index 48f8ffc60f8f..e511e569bbc9 100644
>> --- a/net/rds/rds.h
>> +++ b/net/rds/rds.h
>> @@ -706,7 +706,7 @@ void rds_inc_put(struct rds_incoming *inc);
>>  void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, _=
_be32 daddr,
>>  		       struct rds_incoming *inc, gfp_t gfp);
>>  int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msg=
hdr *msg,
>> -		size_t size, int msg_flags);
>> +		size_t size, int msg_flags, long *timeop);
>>  void rds_clear_recv_queue(struct rds_sock *rs);
>>  int rds_notify_queue_get(struct rds_sock *rs, struct msghdr *msg);
>>  void rds_inc_info_copy(struct rds_incoming *inc,
>> diff --git a/net/rds/recv.c b/net/rds/recv.c
>> index bd82522534fc..6223a4b0fded 100644
>> --- a/net/rds/recv.c
>> +++ b/net/rds/recv.c
>> @@ -396,7 +396,7 @@ static int rds_cmsg_recv(struct rds_incoming *in=
c, struct msghdr *msg)
>>  }
>> =20
>>  int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msg=
hdr *msg,
>> -		size_t size, int msg_flags)
>> +		size_t size, int msg_flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct rds_sock *rs =3D rds_sk_to_rs(sk);
>> @@ -406,7 +406,7 @@ int rds_recvmsg(struct kiocb *iocb, struct socke=
t *sock, struct msghdr *msg,
>>  	struct rds_incoming *inc =3D NULL;
>> =20
>>  	/* udp_recvmsg()->sock_recvtimeo() gets away without locking too..=
 */
>> -	timeo =3D sock_rcvtimeo(sk, nonblock);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, nonblock);
>> =20
>>  	rdsdebug("size %zu flags 0x%x timeo %ld\n", size, msg_flags, timeo=
);
>> =20
>> @@ -493,6 +493,8 @@ int rds_recvmsg(struct kiocb *iocb, struct socke=
t *sock, struct msghdr *msg,
>>  		rds_inc_put(inc);
>> =20
>>  out:
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return ret;
>>  }
>> =20
>> diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
>> index 8451c8cdc9de..2cfc75a1cbbb 100644
>> --- a/net/rose/af_rose.c
>> +++ b/net/rose/af_rose.c
>> @@ -1212,7 +1212,7 @@ static int rose_sendmsg(struct kiocb *iocb, st=
ruct socket *sock,
>> =20
>> =20
>>  static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -			struct msghdr *msg, size_t size, int flags)
>> +			struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct rose_sock *rose =3D rose_sk(sk);
>> @@ -1229,7 +1229,7 @@ static int rose_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
>>  		return -ENOTCONN;
>> =20
>>  	/* Now we can treat all alike */
>> -	if ((skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & =
MSG_DONTWAIT, &er)) =3D=3D NULL)
>> +	if ((skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & =
MSG_DONTWAIT, &er, timeop)) =3D=3D NULL)
>>  		return er;
>> =20
>>  	qbit =3D (skb->data[0] & ROSE_Q_BIT) =3D=3D ROSE_Q_BIT;
>> diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
>> index 63b21e580de9..2319fae4b1f6 100644
>> --- a/net/rxrpc/ar-input.c
>> +++ b/net/rxrpc/ar-input.c
>> @@ -655,7 +655,7 @@ void rxrpc_data_ready(struct sock *sk)
>>  		return;
>>  	}
>> =20
>> -	skb =3D skb_recv_datagram(sk, 0, 1, &ret);
>> +	skb =3D skb_recv_datagram(sk, 0, 1, &ret, NULL);
>>  	if (!skb) {
>>  		rxrpc_put_local(local);
>>  		if (ret =3D=3D -EAGAIN)
>> diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
>> index ba9fd36d3f15..a21e51937e27 100644
>> --- a/net/rxrpc/ar-internal.h
>> +++ b/net/rxrpc/ar-internal.h
>> @@ -573,7 +573,7 @@ extern const struct file_operations rxrpc_connec=
tion_seq_fops;
>>   */
>>  void rxrpc_remove_user_ID(struct rxrpc_sock *, struct rxrpc_call *)=
;
>>  int rxrpc_recvmsg(struct kiocb *, struct socket *, struct msghdr *,=
 size_t,
>> -		  int);
>> +		  int, long *);
>> =20
>>  /*
>>   * ar-security.c
>> diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
>> index e9aaa65c0778..e9082ed598cd 100644
>> --- a/net/rxrpc/ar-recvmsg.c
>> +++ b/net/rxrpc/ar-recvmsg.c
>> @@ -44,7 +44,7 @@ void rxrpc_remove_user_ID(struct rxrpc_sock *rx, s=
truct rxrpc_call *call)
>>   *   simultaneously
>>   */
>>  int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -		  struct msghdr *msg, size_t len, int flags)
>> +		  struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	struct rxrpc_skb_priv *sp;
>>  	struct rxrpc_call *call =3D NULL, *continue_call =3D NULL;
>> @@ -63,7 +63,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socke=
t *sock,
>> =20
>>  	ullen =3D msg->msg_flags & MSG_CMSG_COMPAT ? 4 : sizeof(unsigned l=
ong);
>> =20
>> -	timeo =3D sock_rcvtimeo(&rx->sk, flags & MSG_DONTWAIT);
>> +	timeo =3D sock_rcvtimeop(&rx->sk, timeop, flags & MSG_DONTWAIT);
>>  	msg->msg_flags |=3D MSG_MORE;
>> =20
>>  	lock_sock(&rx->sk);
>> @@ -78,7 +78,8 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socke=
t *sock,
>>  				release_sock(&rx->sk);
>>  				if (continue_call)
>>  					rxrpc_put_call(continue_call);
>> -				return -ENODATA;
>> +				copied =3D -ENODATA;
>> +				goto out_copied;
>>  			}
>>  		}
>> =20
>> @@ -135,7 +136,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct soc=
ket *sock,
>>  				release_sock(&rx->sk);
>>  				rxrpc_put_call(continue_call);
>>  				_leave(" =3D %d [noncont]", copied);
>> -				return copied;
>> +				goto out_copied;
>>  			}
>>  		}
>> =20
>> @@ -252,6 +253,9 @@ out:
>>  	if (continue_call)
>>  		rxrpc_put_call(continue_call);
>>  	_leave(" =3D %d [data]", copied);
>> +out_copied:
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return copied;
>> =20
>>  	/* handle non-DATA messages such as aborts, incoming connections a=
nd
>> @@ -328,7 +332,8 @@ terminal_message:
>>  	if (continue_call)
>>  		rxrpc_put_call(continue_call);
>>  	_leave(" =3D %d", ret);
>> -	return ret;
>> +	copied =3D ret;
>> +	goto out_copied;
>> =20
>>  copy_error:
>>  	_debug("copy error");
>> @@ -337,7 +342,8 @@ copy_error:
>>  	if (continue_call)
>>  		rxrpc_put_call(continue_call);
>>  	_leave(" =3D %d", ret);
>> -	return ret;
>> +	copied =3D ret;
>> +	goto out_copied;
>> =20
>>  wait_interrupted:
>>  	ret =3D sock_intr_errno(timeo);
>> @@ -348,8 +354,7 @@ wait_error:
>>  	if (copied)
>>  		copied =3D ret;
>>  	_leave(" =3D %d [waitfail %d]", copied, ret);
>> -	return copied;
>> -
>> +	goto out_copied;
>>  }
>> =20
>>  /**
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 429899689408..d05161a168bc 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -2042,11 +2042,11 @@ static int sctp_skb_pull(struct sk_buff *skb=
, int len)
>>   *  flags   - flags sent or received with the user message, see Sec=
tion
>>   *            5 for complete description of the flags.
>>   */
>> -static struct sk_buff *sctp_skb_recv_datagram(struct sock *, int, i=
nt, int *);
>> +static struct sk_buff *sctp_skb_recv_datagram(struct sock *, int, i=
nt, int *, long *);
>> =20
>>  static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
>>  			struct msghdr *msg, size_t len, int noblock,
>> -			int flags, int *addr_len)
>> +			int flags, int *addr_len, long *timeop)
>>  {
>>  	struct sctp_ulpevent *event =3D NULL;
>>  	struct sctp_sock *sp =3D sctp_sk(sk);
>> @@ -2066,7 +2066,7 @@ static int sctp_recvmsg(struct kiocb *iocb, st=
ruct sock *sk,
>>  		goto out;
>>  	}
>> =20
>> -	skb =3D sctp_skb_recv_datagram(sk, flags, noblock, &err);
>> +	skb =3D sctp_skb_recv_datagram(sk, flags, noblock, &err, timeop);
>>  	if (!skb)
>>  		goto out;
>> =20
>> @@ -6519,13 +6519,13 @@ out:
>>   * with a few changes to make lksctp work.
>>   */
>>  static struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int =
flags,
>> -					      int noblock, int *err)
>> +					      int noblock, int *err, long *timeop)
>>  {
>>  	int error;
>>  	struct sk_buff *skb;
>>  	long timeo;
>> =20
>> -	timeo =3D sock_rcvtimeo(sk, noblock);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, noblock);
>> =20
>>  	pr_debug("%s: timeo:%ld, max:%ld\n", __func__, timeo,
>>  		 MAX_SCHEDULE_TIMEOUT);
>> @@ -6549,7 +6549,7 @@ static struct sk_buff *sctp_skb_recv_datagram(=
struct sock *sk, int flags,
>>  		}
>> =20
>>  		if (skb)
>> -			return skb;
>> +			break;
>> =20
>>  		/* Caller is allowed not to check sk->sk_err before calling. */
>>  		error =3D sock_error(sk);
>> @@ -6569,11 +6569,15 @@ static struct sk_buff *sctp_skb_recv_datagra=
m(struct sock *sk, int flags,
>>  			goto no_packet;
>>  	} while (sctp_wait_for_packet(sk, err, &timeo) =3D=3D 0);
>> =20
>> -	return NULL;
>> +out:
>> +	if (timeop)
>> +		*timeop =3D timeo;
>> +
>> +	return skb;
>> =20
>>  no_packet:
>>  	*err =3D error;
>> -	return NULL;
>> +	goto out;
>>  }
>> =20
>>  /* If sndbuf has changed, wake up per association sndbuf waiters.  =
*/
>> diff --git a/net/socket.c b/net/socket.c
>> index abf56b2a14f9..310a50971769 100644
>> --- a/net/socket.c
>> +++ b/net/socket.c
>> @@ -772,7 +772,7 @@ void __sock_recv_ts_and_drops(struct msghdr *msg=
, struct sock *sk,
>>  EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
>> =20
>>  static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct s=
ocket *sock,
>> -				       struct msghdr *msg, size_t size, int flags)
>> +				       struct msghdr *msg, size_t size, int flags, long *timeop=
)
>>  {
>>  	struct sock_iocb *si =3D kiocb_to_siocb(iocb);
>> =20
>> @@ -782,19 +782,19 @@ static inline int __sock_recvmsg_nosec(struct =
kiocb *iocb, struct socket *sock,
>>  	si->size =3D size;
>>  	si->flags =3D flags;
>> =20
>> -	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
>> +	return sock->ops->recvmsg(iocb, sock, msg, size, flags, timeop);
>>  }
>> =20
>>  static inline int __sock_recvmsg(struct kiocb *iocb, struct socket =
*sock,
>> -				 struct msghdr *msg, size_t size, int flags)
>> +				 struct msghdr *msg, size_t size, int flags, long *timeop)
>>  {
>>  	int err =3D security_socket_recvmsg(sock, msg, size, flags);
>> =20
>> -	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
>> +	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags, t=
imeop);
>>  }
>> =20
>>  int sock_recvmsg(struct socket *sock, struct msghdr *msg,
>> -		 size_t size, int flags)
>> +		 size_t size, int flags, long *timeop)
>>  {
>>  	struct kiocb iocb;
>>  	struct sock_iocb siocb;
>> @@ -802,7 +802,7 @@ int sock_recvmsg(struct socket *sock, struct msg=
hdr *msg,
>> =20
>>  	init_sync_kiocb(&iocb, NULL);
>>  	iocb.private =3D &siocb;
>> -	ret =3D __sock_recvmsg(&iocb, sock, msg, size, flags);
>> +	ret =3D __sock_recvmsg(&iocb, sock, msg, size, flags, timeop);
>>  	if (-EIOCBQUEUED =3D=3D ret)
>>  		ret =3D wait_on_sync_kiocb(&iocb);
>>  	return ret;
>> @@ -810,7 +810,7 @@ int sock_recvmsg(struct socket *sock, struct msg=
hdr *msg,
>>  EXPORT_SYMBOL(sock_recvmsg);
>> =20
>>  static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *m=
sg,
>> -			      size_t size, int flags)
>> +			      size_t size, int flags, long *timeop)
>>  {
>>  	struct kiocb iocb;
>>  	struct sock_iocb siocb;
>> @@ -818,7 +818,7 @@ static int sock_recvmsg_nosec(struct socket *soc=
k, struct msghdr *msg,
>> =20
>>  	init_sync_kiocb(&iocb, NULL);
>>  	iocb.private =3D &siocb;
>> -	ret =3D __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
>> +	ret =3D __sock_recvmsg_nosec(&iocb, sock, msg, size, flags, timeop=
);
>>  	if (-EIOCBQUEUED =3D=3D ret)
>>  		ret =3D wait_on_sync_kiocb(&iocb);
>>  	return ret;
>> @@ -851,7 +851,7 @@ int kernel_recvmsg(struct socket *sock, struct m=
sghdr *msg,
>>  	 * iovec are identical, yielding the same in-core layout and align=
ment
>>  	 */
>>  	msg->msg_iov =3D (struct iovec *)vec, msg->msg_iovlen =3D num;
>> -	result =3D sock_recvmsg(sock, msg, size, flags);
>> +	result =3D sock_recvmsg(sock, msg, size, flags, NULL);
>>  	set_fs(oldfs);
>>  	return result;
>>  }
>> @@ -914,7 +914,7 @@ static ssize_t do_sock_read(struct msghdr *msg, =
struct kiocb *iocb,
>>  	msg->msg_iovlen =3D nr_segs;
>>  	msg->msg_flags =3D (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0=
;
>> =20
>> -	return __sock_recvmsg(iocb, sock, msg, size, msg->msg_flags);
>> +	return __sock_recvmsg(iocb, sock, msg, size, msg->msg_flags, NULL)=
;
>>  }
>> =20
>>  static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec=
 *iov,
>> @@ -1862,7 +1862,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user=
 *, ubuf, size_t, size,
>>  	msg.msg_namelen =3D 0;
>>  	if (sock->file->f_flags & O_NONBLOCK)
>>  		flags |=3D MSG_DONTWAIT;
>> -	err =3D sock_recvmsg(sock, &msg, size, flags);
>> +	err =3D sock_recvmsg(sock, &msg, size, flags, NULL);
>> =20
>>  	if (err >=3D 0 && addr !=3D NULL) {
>>  		err2 =3D move_addr_to_user(&address,
>> @@ -2207,7 +2207,7 @@ SYSCALL_DEFINE4(sendmmsg, int, fd, struct mmsg=
hdr __user *, mmsg,
>>  }
>> =20
>>  static int ___sys_recvmsg(struct socket *sock, struct msghdr __user=
 *msg,
>> -			 struct msghdr *msg_sys, unsigned int flags, int nosec)
>> +			 struct msghdr *msg_sys, unsigned int flags, int nosec, long *ti=
meop)
>>  {
>>  	struct compat_msghdr __user *msg_compat =3D
>>  	    (struct compat_msghdr __user *)msg;
>> @@ -2265,7 +2265,7 @@ static int ___sys_recvmsg(struct socket *sock,=
 struct msghdr __user *msg,
>>  	if (sock->file->f_flags & O_NONBLOCK)
>>  		flags |=3D MSG_DONTWAIT;
>>  	err =3D (nosec ? sock_recvmsg_nosec : sock_recvmsg)(sock, msg_sys,
>> -							  total_len, flags);
>> +							  total_len, flags, timeop);
>>  	if (err < 0)
>>  		goto out_freeiov;
>>  	len =3D err;
>> @@ -2312,7 +2312,7 @@ long __sys_recvmsg(int fd, struct msghdr __use=
r *msg, unsigned flags)
>>  	if (!sock)
>>  		goto out;
>> =20
>> -	err =3D ___sys_recvmsg(sock, msg, &msg_sys, flags, 0);
>> +	err =3D ___sys_recvmsg(sock, msg, &msg_sys, flags, 0, NULL);
>> =20
>>  	fput_light(sock->file, fput_needed);
>>  out:
>> @@ -2327,6 +2327,30 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msgh=
dr __user *, msg,
>>  	return __sys_recvmsg(fd, msg, flags);
>>  }
>> =20
>> +static int sock_set_timeout_ts(long *timeo_p, struct timespec *ts)
>> +{
>> +	if (ts->tv_nsec < 0 || ts->tv_nsec >=3D NSEC_PER_SEC)
>> +		return -EDOM;
>> +
>> +	if (ts->tv_sec < 0) {
>> +		static int warned __read_mostly;
>> +
>> +		*timeo_p =3D 0;
>> +		if (warned < 10 && net_ratelimit()) {
>> +			warned++;
>> +			pr_info("%s: `%s' (pid %d) tries to set negative timeout\n",
>> +				__func__, current->comm, task_pid_nr(current));
>> +		}
>> +		return 0;
>> +	}
>> +	*timeo_p =3D MAX_SCHEDULE_TIMEOUT;
>> +	if (ts->tv_sec =3D=3D 0 && ts->tv_nsec =3D=3D 0)
>> +		return 0;
>> +	if (ts->tv_sec < (MAX_SCHEDULE_TIMEOUT / HZ - 1))
>> +		*timeo_p =3D ts->tv_sec * HZ + (ts->tv_nsec + (NSEC_PER_SEC / HZ =
- 1)) / (NSEC_PER_SEC / HZ);
>> +	return 0;
>> +}
>> +
>>  /*
>>   *     Linux recvmmsg interface
>>   */
>> @@ -2339,12 +2363,14 @@ int __sys_recvmmsg(int fd, struct mmsghdr __=
user *mmsg, unsigned int vlen,
>>  	struct mmsghdr __user *entry;
>>  	struct compat_mmsghdr __user *compat_entry;
>>  	struct msghdr msg_sys;
>> -	struct timespec end_time;
>> +	long timeout_hz, *timeop =3D NULL;
>> =20
>> -	if (timeout &&
>> -	    poll_select_set_timeout(&end_time, timeout->tv_sec,
>> -				    timeout->tv_nsec))
>> -		return -EINVAL;
>> +	if (timeout) {
>> +		err =3D sock_set_timeout_ts(&timeout_hz, timeout);
>> +		if (err)
>> +			return err;
>> +		timeop =3D &timeout_hz;
>> +	}
>> =20
>>  	datagrams =3D 0;
>> =20
>> @@ -2366,7 +2392,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __us=
er *mmsg, unsigned int vlen,
>>  		if (MSG_CMSG_COMPAT & flags) {
>>  			err =3D ___sys_recvmsg(sock, (struct msghdr __user *)compat_entr=
y,
>>  					     &msg_sys, flags & ~MSG_WAITFORONE,
>> -					     datagrams);
>> +					     datagrams, timeop);
>>  			if (err < 0)
>>  				break;
>>  			err =3D __put_user(err, &compat_entry->msg_len);
>> @@ -2375,7 +2401,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __us=
er *mmsg, unsigned int vlen,
>>  			err =3D ___sys_recvmsg(sock,
>>  					     (struct msghdr __user *)entry,
>>  					     &msg_sys, flags & ~MSG_WAITFORONE,
>> -					     datagrams);
>> +					     datagrams, timeop);
>>  			if (err < 0)
>>  				break;
>>  			err =3D put_user(err, &entry->msg_len);
>> @@ -2390,17 +2416,11 @@ int __sys_recvmmsg(int fd, struct mmsghdr __=
user *mmsg, unsigned int vlen,
>>  		if (flags & MSG_WAITFORONE)
>>  			flags |=3D MSG_DONTWAIT;
>> =20
>> -		if (timeout) {
>> -			ktime_get_ts(timeout);
>> -			*timeout =3D timespec_sub(end_time, *timeout);
>> -			if (timeout->tv_sec < 0) {
>> -				timeout->tv_sec =3D timeout->tv_nsec =3D 0;
>> -				break;
>> -			}
>> -
>> +		if (timeout && timeout_hz =3D=3D 0) {
>>  			/* Timeout, return less than vlen datagrams */
>> -			if (timeout->tv_nsec =3D=3D 0 && timeout->tv_sec =3D=3D 0)
>> -				break;
>> +			timeout->tv_sec =3D timeout->tv_nsec =3D 0;
>> +			timeop =3D NULL;
>> +			break;
>>  		}
>> =20
>>  		/* Out of band data, return right away */
>> @@ -2411,6 +2431,11 @@ int __sys_recvmmsg(int fd, struct mmsghdr __u=
ser *mmsg, unsigned int vlen,
>>  out_put:
>>  	fput_light(sock->file, fput_needed);
>> =20
>> +	if (timeop) {
>> +		timeout->tv_sec	 =3D timeout_hz / HZ;
>> +		timeout->tv_nsec =3D (timeout_hz % HZ) * (NSEC_PER_SEC / HZ);
>> +	}
>> +
>>  	if (err =3D=3D 0)
>>  		return datagrams;
>> =20
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index b507cd327d9b..92417723f9dc 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -551,7 +551,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqs=
tp)
>>  	err =3D kernel_recvmsg(svsk->sk_sock, &msg, NULL,
>>  			     0, 0, MSG_PEEK | MSG_DONTWAIT);
>>  	if (err >=3D 0)
>> -		skb =3D skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
>> +		skb =3D skb_recv_datagram(svsk->sk_sk, 0, 1, &err, NULL);
>> =20
>>  	if (skb =3D=3D NULL) {
>>  		if (err !=3D -EAGAIN) {
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index be8bbd5d65ec..1afb8ece3eb6 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -965,7 +965,7 @@ static void xs_local_data_ready(struct sock *sk)
>>  	if (xprt =3D=3D NULL)
>>  		goto out;
>> =20
>> -	skb =3D skb_recv_datagram(sk, 0, 1, &err);
>> +	skb =3D skb_recv_datagram(sk, 0, 1, &err, NULL);
>>  	if (skb =3D=3D NULL)
>>  		goto out;
>> =20
>> @@ -1027,7 +1027,7 @@ static void xs_udp_data_ready(struct sock *sk)
>>  	if (!(xprt =3D xprt_from_sock(sk)))
>>  		goto out;
>> =20
>> -	if ((skb =3D skb_recv_datagram(sk, 0, 1, &err)) =3D=3D NULL)
>> +	if ((skb =3D skb_recv_datagram(sk, 0, 1, &err, NULL)) =3D=3D NULL)
>>  		goto out;
>> =20
>>  	repsize =3D skb->len - sizeof(struct udphdr);
>> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
>> index ef0475568f9e..70699525a102 100644
>> --- a/net/tipc/socket.c
>> +++ b/net/tipc/socket.c
>> @@ -1031,7 +1031,7 @@ static int tipc_wait_for_rcvmsg(struct socket =
*sock, long *timeop)
>>   * Returns size of returned message data, errno otherwise
>>   */
>>  static int tipc_recvmsg(struct kiocb *iocb, struct socket *sock,
>> -			struct msghdr *m, size_t buf_len, int flags)
>> +			struct msghdr *m, size_t buf_len, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct tipc_sock *tsk =3D tipc_sk(sk);
>> @@ -1054,7 +1054,7 @@ static int tipc_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
>>  		goto exit;
>>  	}
>> =20
>> -	timeo =3D sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
>> +	timeo =3D sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
>>  restart:
>> =20
>>  	/* Look for a message in receive queue; wait if necessary */
>> @@ -1109,6 +1109,8 @@ restart:
>>  		advance_rx_queue(sk);
>>  	}
>>  exit:
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	release_sock(sk);
>>  	return res;
>>  }
>> @@ -1126,7 +1128,7 @@ exit:
>>   * Returns size of returned message data, errno otherwise
>>   */
>>  static int tipc_recv_stream(struct kiocb *iocb, struct socket *sock=
,
>> -			    struct msghdr *m, size_t buf_len, int flags)
>> +			    struct msghdr *m, size_t buf_len, int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct tipc_sock *tsk =3D tipc_sk(sk);
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index e96884380732..dcca71ed08c6 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -519,17 +519,17 @@ static int unix_shutdown(struct socket *, int)=
;
>>  static int unix_stream_sendmsg(struct kiocb *, struct socket *,
>>  			       struct msghdr *, size_t);
>>  static int unix_stream_recvmsg(struct kiocb *, struct socket *,
>> -			       struct msghdr *, size_t, int);
>> +			       struct msghdr *, size_t, int, long *);
>>  static int unix_dgram_sendmsg(struct kiocb *, struct socket *,
>>  			      struct msghdr *, size_t);
>>  static int unix_dgram_recvmsg(struct kiocb *, struct socket *,
>> -			      struct msghdr *, size_t, int);
>> +			      struct msghdr *, size_t, int, long *);
>>  static int unix_dgram_connect(struct socket *, struct sockaddr *,
>>  			      int, int);
>>  static int unix_seqpacket_sendmsg(struct kiocb *, struct socket *,
>>  				  struct msghdr *, size_t);
>>  static int unix_seqpacket_recvmsg(struct kiocb *, struct socket *,
>> -				  struct msghdr *, size_t, int);
>> +				  struct msghdr *, size_t, int, long *);
>> =20
>>  static int unix_set_peek_off(struct sock *sk, int val)
>>  {
>> @@ -1283,7 +1283,7 @@ static int unix_accept(struct socket *sock, st=
ruct socket *newsock, int flags)
>>  	 * so that no locks are necessary.
>>  	 */
>> =20
>> -	skb =3D skb_recv_datagram(sk, 0, flags&O_NONBLOCK, &err);
>> +	skb =3D skb_recv_datagram(sk, 0, flags&O_NONBLOCK, &err, NULL);
>>  	if (!skb) {
>>  		/* This means receive shutdown. */
>>  		if (err =3D=3D 0)
>> @@ -1755,14 +1755,14 @@ static int unix_seqpacket_sendmsg(struct kio=
cb *kiocb, struct socket *sock,
>> =20
>>  static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket=
 *sock,
>>  			      struct msghdr *msg, size_t size,
>> -			      int flags)
>> +			      int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>> =20
>>  	if (sk->sk_state !=3D TCP_ESTABLISHED)
>>  		return -ENOTCONN;
>> =20
>> -	return unix_dgram_recvmsg(iocb, sock, msg, size, flags);
>> +	return unix_dgram_recvmsg(iocb, sock, msg, size, flags, timeop);
>>  }
>> =20
>>  static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
>> @@ -1777,7 +1777,7 @@ static void unix_copy_addr(struct msghdr *msg,=
 struct sock *sk)
>> =20
>>  static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *so=
ck,
>>  			      struct msghdr *msg, size_t size,
>> -			      int flags)
>> +			      int flags, long *timeop)
>>  {
>>  	struct sock_iocb *siocb =3D kiocb_to_siocb(iocb);
>>  	struct scm_cookie tmp_scm;
>> @@ -1803,7 +1803,7 @@ static int unix_dgram_recvmsg(struct kiocb *io=
cb, struct socket *sock,
>> =20
>>  	skip =3D sk_peek_offset(sk, flags);
>> =20
>> -	skb =3D __skb_recv_datagram(sk, flags, &peeked, &skip, &err);
>> +	skb =3D __skb_recv_datagram(sk, flags, &peeked, &skip, &err, timeo=
p);
>>  	if (!skb) {
>>  		unix_state_lock(sk);
>>  		/* Signal EOF on disconnected non-blocking SEQPACKET socket. */
>> @@ -1914,7 +1914,7 @@ static unsigned int unix_skb_len(const struct =
sk_buff *skb)
>> =20
>>  static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *s=
ock,
>>  			       struct msghdr *msg, size_t size,
>> -			       int flags)
>> +			       int flags, long *timeop)
>>  {
>>  	struct sock_iocb *siocb =3D kiocb_to_siocb(iocb);
>>  	struct scm_cookie tmp_scm;
>> @@ -1926,7 +1926,7 @@ static int unix_stream_recvmsg(struct kiocb *i=
ocb, struct socket *sock,
>>  	int check_creds =3D 0;
>>  	int target;
>>  	int err =3D 0;
>> -	long timeo;
>> +	long timeo =3D sock_rcvtimeop(sk, timeop, noblock);
>>  	int skip;
>> =20
>>  	err =3D -EINVAL;
>> @@ -1938,7 +1938,6 @@ static int unix_stream_recvmsg(struct kiocb *i=
ocb, struct socket *sock,
>>  		goto out;
>> =20
>>  	target =3D sock_rcvlowat(sk, flags&MSG_WAITALL, size);
>> -	timeo =3D sock_rcvtimeo(sk, noblock);
>> =20
>>  	/* Lock the socket to prevent queue disordering
>>  	 * while sleeps in memcpy_tomsg
>> @@ -2071,6 +2070,8 @@ again:
>>  	mutex_unlock(&u->readlock);
>>  	scm_recv(sock, msg, siocb->scm, flags);
>>  out:
>> +	if (timeop)
>> +		*timeop =3D timeo;
>>  	return copied ? : err;
>>  }
>> =20
>> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
>> index 85d232bed87d..10568565f57d 100644
>> --- a/net/vmw_vsock/af_vsock.c
>> +++ b/net/vmw_vsock/af_vsock.c
>> @@ -1063,10 +1063,10 @@ out:
>>  }
>> =20
>>  static int vsock_dgram_recvmsg(struct kiocb *kiocb, struct socket *=
sock,
>> -			       struct msghdr *msg, size_t len, int flags)
>> +			       struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	return transport->dgram_dequeue(kiocb, vsock_sk(sock->sk), msg, le=
n,
>> -					flags);
>> +					flags, timeop);
>>  }
>> =20
>>  static const struct proto_ops vsock_dgram_ops =3D {
>> @@ -1646,7 +1646,7 @@ out:
>>  static int
>>  vsock_stream_recvmsg(struct kiocb *kiocb,
>>  		     struct socket *sock,
>> -		     struct msghdr *msg, size_t len, int flags)
>> +		     struct msghdr *msg, size_t len, int flags, long *timeop)
>>  {
>>  	struct sock *sk;
>>  	struct vsock_sock *vsk;
>> @@ -1661,6 +1661,7 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
>>  	sk =3D sock->sk;
>>  	vsk =3D vsock_sk(sk);
>>  	err =3D 0;
>> +	timeout =3D sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
>> =20
>>  	lock_sock(sk);
>> =20
>> @@ -1711,7 +1712,6 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
>>  		err =3D -ENOMEM;
>>  		goto out;
>>  	}
>> -	timeout =3D sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
>>  	copied =3D 0;
>> =20
>>  	err =3D transport->notify_recv_init(vsk, target, &recv_data);
>> @@ -1821,6 +1821,8 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
>>  out_wait:
>>  	finish_wait(sk_sleep(sk), &wait);
>>  out:
>> +	if (timeop)
>> +		*timeop =3D timeout;
>>  	release_sock(sk);
>>  	return err;
>>  }
>> diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_tra=
nsport.c
>> index 9bb63ffec4f2..9c9e43c17b34 100644
>> --- a/net/vmw_vsock/vmci_transport.c
>> +++ b/net/vmw_vsock/vmci_transport.c
>> @@ -1733,7 +1733,7 @@ static int vmci_transport_dgram_enqueue(
>>  static int vmci_transport_dgram_dequeue(struct kiocb *kiocb,
>>  					struct vsock_sock *vsk,
>>  					struct msghdr *msg, size_t len,
>> -					int flags)
>> +					int flags, long *timeop)
>>  {
>>  	int err;
>>  	int noblock;
>> @@ -1748,7 +1748,7 @@ static int vmci_transport_dgram_dequeue(struct=
 kiocb *kiocb,
>> =20
>>  	/* Retrieve the head sk_buff from the socket's receive queue. */
>>  	err =3D 0;
>> -	skb =3D skb_recv_datagram(&vsk->sk, flags, noblock, &err);
>> +	skb =3D skb_recv_datagram(&vsk->sk, flags, noblock, &err, timeop);
>>  	if (err)
>>  		return err;
>> =20
>> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
>> index 5ad4418ef093..da22c042469a 100644
>> --- a/net/x25/af_x25.c
>> +++ b/net/x25/af_x25.c
>> @@ -1254,7 +1254,7 @@ out_kfree_skb:
>> =20
>>  static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
>>  		       struct msghdr *msg, size_t size,
>> -		       int flags)
>> +		       int flags, long *timeop)
>>  {
>>  	struct sock *sk =3D sock->sk;
>>  	struct x25_sock *x25 =3D x25_sk(sk);
>> @@ -1306,7 +1306,7 @@ static int x25_recvmsg(struct kiocb *iocb, str=
uct socket *sock,
>>  		/* Now we can treat all alike */
>>  		release_sock(sk);
>>  		skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>> -					flags & MSG_DONTWAIT, &rc);
>> +					flags & MSG_DONTWAIT, &rc, timeop);
>>  		lock_sock(sk);
>>  		if (!skb)
>>  			goto out;
>>
>=20
>=20


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
