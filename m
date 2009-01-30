From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 09:57:37 -0800
Message-ID: <20090130095737.103edbff@extreme>
References: <20090130112125.GA9908@ioremap.net>
	<20090130125337.GA7155@gondor.apana.org.au>
Reply-To: Fedora/Linux Management Tools <et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <20090130125337.GA7155-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/et-mgmt-tools>
List-Post: <mailto:et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Help: <mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=subscribe>
Sender: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Errors-To: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Jan 2009 23:53:37 +1100
Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> wrote:

> Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org> wrote:
> >
> > So it is not explicit bind call, but port autoselection in the
> > connect(). Can you check what errno is returned?
> > Did I understand it right, that connect fails, you try different
> > address, but then suddenly all those sockets become 'alive'?
> 
> Yes, I think a good strace vs. a bad strace would be really helpful
> in these cases.
> 
> Thanks,

I have the strace but it comes up no different.
What is different is that in the broken case (net-next), I see
IPV6 being used:

State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
ESTAB      23769  0        ::ffff:127.0.0.1:5900      ::ffff:127.0.0.1:55987   
ESTAB      0      0               127.0.0.1:55987            127.0.0.1:5900

and in the working case (2.6.29-rc3), IPV4 is being used
State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
ESTAB      0      0               127.0.0.1:58894            127.0.0.1:5901    
ESTAB      0      0               127.0.0.1:5901             127.0.0.1:58894 

Relevant bits of strace in broken case are:

7276  socket(PF_NETLINK, SOCK_RAW, 0)   = 21
7276  bind(21, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
7276  getsockname(21, {sa_family=AF_NETLINK, pid=7276, groups=00000000}, [66387309494284]) = 0
7276  sendto(21, "\24\0\0\0\26\0\1\3\353<\203I\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
7276  recvmsg(21, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"0\0\0\0\24\0\2\0\353<\203Il\34\0\0\2\10\200\376\1\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 168
7276  recvmsg(21, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"@\0\0\0\24\0\2\0\353<\203Il\34\0\0\n\200\200\376\1\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 256
7276  recvmsg(21, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\353<\203Il\34\0\0\0\0\0\0\1\0\0\0\24"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
7276  close(21)                         = 0
7276  socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 21
7276  fcntl(21, F_GETFL)                = 0x2 (flags O_RDWR)
7276  fcntl(21, F_SETFL, O_RDWR|O_NONBLOCK) = 0
7276  fstat(21, {st_mode=S_IFSOCK|0777, st_size=0, ...}) = 0
7276  fcntl(21, F_GETFL)                = 0x802 (flags O_RDWR|O_NONBLOCK)
7276  connect(21, {sa_family=AF_INET, sin_port=htons(5900), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EINPROGRESS (Operation now in progress)
7276  rt_sigprocmask(SIG_BLOCK, NULL, [], 8) = 0
7276  rt_sigprocmask(SIG_SETMASK, [], [], 8) = 0
7276  read(5, 0xca5af4, 4096)           = -1 EAGAIN (Resource temporarily unavailable)
7276  poll([{fd=5, events=POLLIN}, {fd=4, events=POLLIN}, {fd=10, events=POLLIN|POLLPRI}, {fd=12, events=POLLIN|POLLPRI}, {fd=13, events=POLLIN|POLLPRI}, {fd=14, events=POLLIN|POLLPRI}, {fd=15, events=POLLIN}, {fd=16, events=POLLIN}, {fd=17, events=POLLIN}, {fd=18, events=POLLIN}, {fd=21, events=POLLOUT, revents=POLLOUT}], 11, 844) = 1
7276  read(18, 0x7fff4fa96a1f, 1)       = -1 EAGAIN (Resource temporarily unavailable)
7276  rt_sigprocmask(SIG_BLOCK, NULL, [], 8) = 0
7276  rt_sigprocmask(SIG_SETMASK, [], [], 8) = 0
7276  connect(21, {sa_family=AF_INET, sin_port=htons(5900), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
7276  rt_sigprocmask(SIG_BLOCK, NULL, [], 8) = 0
7276  rt_sigprocmask(SIG_SETMASK, [], [], 8) = 0
7276  read(5, 0xca5af4, 4096)           = -1 EAGAIN (Resource temporarily unavailable)
7276  poll([{fd=5, events=POLLIN}, {fd=4, events=POLLIN}, {fd=10, events=POLLIN|POLLPRI}, {fd=12, events=POLLIN|POLLPRI}, {fd=13, events=POLLIN|POLLPRI}, {fd=14, events=POLLIN|POLLPRI}, {fd=15, events=POLLIN}, {fd=16, events=POLLIN}, {fd=17, events=POLLIN}, {fd=18, events=POLLIN}], 10, 0) = 0
7276  read(18, 0x7fff4fa96a1f, 1)       = -1 EAGAIN (Resource temporarily unavailable)
7276  rt_sigprocmask(SIG_BLOCK, NULL, [], 8) = 0
7276  rt_sigprocmask(SIG_SETMASK, [], [], 8) = 0
7276  read(21, "RFB 003.007\n", 4096)   = 12
7276  write(21, "RFB 003.007\0", 12)    = 12
7276  read(21, 0x18c5170, 4096)         = -1 EAGAIN (Resource temporarily unavailable)
7276  rt_sigprocmask(SIG_BLOCK, NULL, [], 8) = 0
7276  rt_sigprocmask(SIG_SETMASK, [], [], 8) = 0
7276  read(5, 0xca5af4, 4096)           = -1 EAGAIN (Resource temporarily unavailable)
7276  poll([{fd=5, events=POLLIN}, {fd=4, events=POLLIN}, {fd=10, events=POLLIN|POLLPRI}, {fd=12, events=POLLIN|POLLPRI}, {fd=13, events=POLLIN|POLLPRI}, {fd=14, events=POLLIN|POLLPRI}, {fd=15, events=POLLIN}, {fd=16, events=POLLIN}, {fd=17, events=POLLIN}, {fd=18, events=POLLIN}, {fd=21, events=POLLIN, revents=POLLIN}], 11, 842) = 1
7276  read(18, 0x7fff4fa96a1f, 1)       = -1 EAGAIN (Resource temporarily unavailable)
7276  rt_sigprocmask(SIG_BLOCK, NULL, [], 8) = 0
7276  rt_sigprocmask(SIG_SETMASK, [], [], 8) = 0
7276  read(21, "\2\22\1", 4096)         = 3
7276  write(21, "\22", 1)               = 1
7276  brk(0x1c6b000)                    = 0x1c6b000
7276  access("/dev/random", R_OK)       = 0
7276  access("/dev/urandom", R_OK)      = 0
7276  open("/dev/urandom", O_RDONLY)    = 22
7276  fcntl(22, F_GETFD)                = 0
7276  fcntl(22, F_SETFD, FD_CLOEXEC)    = 0
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999998})
7276  read(22, "\316\n\4!\224\227\215\276\\b\224\272\334,Y\256\4\236\245"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\236\216s*\211\347\\\245\217\2549\24!\242\216\257t\327"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "E\20\376E\322\366W\10t\342\273\2734\217\5\250\212\235\335"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\325\325\355\327\356\323\37\17\256|\34\375\223\4\340\323"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "=\371\222\340\354\21e0\271\5-\337e\273h\207uS \225\321"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "C\316\236\301\315\257{|,\217\253\321 ]W\212\217H\342\222"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, ",{\201\272V\246\257^\t\214\374\377\360\357;\26\226w\370"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\33\330\31\363L\25\243\360+\21J\315\227\251\364y\276\356"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\335u\377\235mf\34-\227\221\"\21y,Y\336a*9\25=H\350\334"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "U\274\270\373\326?Ly\232\24\2a\367\261DA\223N\273M\255"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\221\237PJY\342\260\207z\360W \274\303\360q@E8\246\355"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, ":{\177\347\20\246\373\345M;\243:\35\347j\302\317\2737\244"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\326\317\16\363\27\35\351\226o?@c\251\320\323\0\274\301"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\23N\257I\345\224Fi\364\7M\340\213\321\365\351\253;\4\16"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "p\317 \344\313\273\215\250G0-\212}\202\v(\354\207 \223"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\225\211\206_\2\220\3\222\3523@\353\203J^\324\320;r\206"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\344\251H\230#\244\302x\235\226\315J\364\207\221)\215&"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "3qS\366\343G\372\0)\340\313j\20`\300\3476\215}\35o>\6\305"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\371N9\213\261\230\341\211m/\224h\267lj\2\311\"\374\210"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "^\32ccG\271mh\302\324\244cu\325J\324B\210\245\237&\377"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "N\3463\324\372)\264\310\272\34\25\210POvoA#z\234\362LI"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\362\327g\330i\\\t\10:\357g\243Y\260]\346\235o\337e\30"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\377L\35\272WE\346\256g#\367qK\255\350\323P\323\366\350"..., 120) = 120
7276  select(23, [22], NULL, NULL, {3, 0}) = 1 (in [22], left {2, 999999})
7276  read(22, "\37\31\275\361\302\201/\234\327^m|\362/@\332\356\225`8"..., 120) = 120
