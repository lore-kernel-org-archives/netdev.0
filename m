From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: disablenetwork (v5): Require CAP_SETPCAP to enable
	disablenetwork.
Date: Sat, 16 Jan 2010 18:58:41 -0800
Message-ID: <551280e51001161858q740bf246n2ed389920de689e7@mail.gmail.com>
References: <20100115081028.GA14004@heat> <20100115081308.GA14443@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
To: Michael Stone <michael@laptop.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753363Ab0AQC6t@vger.kernel.org>
In-Reply-To: <20100115081308.GA14443@heat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2010 at 12:13 AM, Michael Stone <michael@laptop.org> wr=
ote:
> We implement this check by allocating a new flag bit in task_struct->=
network
> and by propagating its semantics throughout the disablenetwork facili=
ty.
>
> Signed-off-by: Michael Stone <michael@laptop.org>
> ---
> =A0include/linux/prctl.h =A0 =A0 | =A0 =A08 +++++---
> =A0kernel/sys.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 14 +++++++++++++-
> =A0security/disablenetwork.c | =A0 15 ++++++++-------
> =A03 files changed, 26 insertions(+), 11 deletions(-)
>
> diff --git a/include/linux/prctl.h b/include/linux/prctl.h
> index 4eb4110..4fdb417 100644
> --- a/include/linux/prctl.h
> +++ b/include/linux/prctl.h
> @@ -105,8 +105,10 @@
> =A0/* Get/set process disable-network flags */
> =A0#define PR_SET_NETWORK =A0 =A0 =A0 =A035
> =A0#define PR_GET_NETWORK =A0 =A0 =A0 =A036
> -# define PR_NETWORK_ON =A0 =A0 =A0 =A00
> -# define PR_NETWORK_OFF =A0 =A0 =A0 1
> -# define PR_NETWORK_ALL_FLAGS 1
> +# define PR_NETWORK_ON =A0 =A0 =A0 =A0 0
> +# define PR_NETWORK_ENABLE_DN =A01
> +# define PR_NETWORK_OFF =A0 =A0 =A0 =A02
> +# define PR_NETWORK_ALL_FLAGS =A03
> +# define PR_NETWORK_DN_FLAGS =A0 3
>
> =A0#endif /* _LINUX_PRCTL_H */
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 1fadf10..4c7ef83 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1608,7 +1608,19 @@ long prctl_set_network(unsigned long network_f=
lags)
> =A0 =A0 =A0 =A0if (current->network & ~network_flags)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
>
> - =A0 =A0 =A0 current->network =3D network_flags;
> + =A0 =A0 =A0 /* Only the superuser may permit a process to enable di=
sablenetwork. */
> + =A0 =A0 =A0 if (!(current->network & PR_NETWORK_ENABLE_DN) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 network_flags & PR_NETWORK_ENABLE_DN &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 !capable(CAP_SETPCAP))

Please use CAP_NET_ADMIN for this feature (and add the corresponding
comment in include/linux/capabilities.h).

Thanks

Andrew

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> +
> + =A0 =A0 =A0 /* Only dn-enabled processes may activate disablenetwor=
k. */
> + =A0 =A0 =A0 if (!(current->network & PR_NETWORK_OFF) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 network_flags & PR_NETWORK_OFF &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(current->network & PR_NETWORK_ENABLE_=
DN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> +
> + =A0 =A0 =A0 current->network |=3D network_flags;
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> diff --git a/security/disablenetwork.c b/security/disablenetwork.c
> index 27b88d7..02c0150 100644
> --- a/security/disablenetwork.c
> +++ b/security/disablenetwork.c
> @@ -19,10 +19,11 @@
> =A0#include <net/sock.h>
> =A0#include <linux/socket.h>
> =A0#include <linux/disablenetwork.h>
> +#include <linux/prctl.h>
>
> -static inline int maybe_allow(void)
> +static inline int maybe_allow(unsigned long network_flags)
> =A0{
> - =A0 =A0 =A0 if (current->network)
> + =A0 =A0 =A0 if ((network_flags & PR_NETWORK_DN_FLAGS) =3D=3D PR_NET=
WORK_DN_FLAGS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
> =A0 =A0 =A0 =A0return 0;
> =A0}
> @@ -32,7 +33,7 @@ int disablenetwork_security_socket_create(int famil=
y, int type,
> =A0{
> =A0 =A0 =A0 =A0if (family =3D=3D AF_UNIX)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> - =A0 =A0 =A0 return maybe_allow();
> + =A0 =A0 =A0 return maybe_allow(current->network);
> =A0}
>
> =A0int disablenetwork_security_socket_bind(struct socket * sock,
> @@ -41,7 +42,7 @@ int disablenetwork_security_socket_bind(struct sock=
et * sock,
> =A0{
> =A0 =A0 =A0 =A0if (address->sa_family =3D=3D AF_UNIX)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> - =A0 =A0 =A0 return maybe_allow();
> + =A0 =A0 =A0 return maybe_allow(current->network);
> =A0}
>
> =A0int disablenetwork_security_socket_connect(struct socket * sock,
> @@ -50,7 +51,7 @@ int disablenetwork_security_socket_connect(struct s=
ocket * sock,
> =A0{
> =A0 =A0 =A0 =A0if (address->sa_family =3D=3D AF_UNIX)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> - =A0 =A0 =A0 return maybe_allow();
> + =A0 =A0 =A0 return maybe_allow(current->network);
> =A0}
>
> =A0int disablenetwork_security_socket_sendmsg(struct socket * sock,
> @@ -59,14 +60,14 @@ int disablenetwork_security_socket_sendmsg(struct=
 socket * sock,
> =A0 =A0 =A0 =A0/* permit sockets which are PF_UNIX or connected; chec=
k others. */
> =A0 =A0 =A0 =A0if (sock->sk->sk_family =3D=3D PF_UNIX || msg->msg_nam=
e =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> - =A0 =A0 =A0 return maybe_allow();
> + =A0 =A0 =A0 return maybe_allow(current->network);
> =A0}
>
> =A0int disablenetwork_security_ptrace_access_check(struct task_struct=
 *child,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int mode)
> =A0{
> =A0 =A0 =A0 =A0/* does current have networking restrictions not share=
d by child? */
> - =A0 =A0 =A0 if (current->network & ~child->network)
> + =A0 =A0 =A0 if (maybe_allow(current->network) && !maybe_allow(child=
->network))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
> =A0 =A0 =A0 =A0return 0;
> =A0}
> --
> 1.6.6.rc2
>
