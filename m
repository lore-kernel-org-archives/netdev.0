From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net: socket: NULL ptr deref in sendmsg
Date: Sat, 26 Jul 2014 17:54:40 +0200
Message-ID: <1406390080.22881.75.camel@localhost>
References: <53C2FF3D.4030201@oracle.com> <53D2768E.2040902@samsung.com>
	 <1406326508.13203.10.camel@localhost>
	 <CAPAsAGwc7B2rB+3wTHkL97B5eDchbcuhfkKef56ARCy2CxCGuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPAsAGwc7B2rB+3wTHkL97B5eDchbcuhfkKef56ARCy2CxCGuQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sa, 2014-07-26 at 19:48 +0400, Andrey Ryabinin wrote:
> 2014-07-26 2:15 GMT+04:00 Hannes Frederic Sowa <hannes@stressinduktion.org>:
> > Otherwise I would just set msg_namelen = 0, too, and just not handle
> > passed in NULL pointers to sockaddrs.
> >
> 
> I like that, how about such chage:
> 
> diff --git a/net/compat.c b/net/compat.c
> index 9a76eaf..bc8aeef 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -85,7 +85,7 @@ int verify_compat_iovec(struct msghdr *kern_msg,
> struct iovec *kern_iov,
>  {
>         int tot_len;
> 
> -       if (kern_msg->msg_namelen) {
> +       if (kern_msg->msg_name && kern_msg->msg_namelen) {
>                 if (mode == VERIFY_READ) {
>                         int err = move_addr_to_kernel(kern_msg->msg_name,
>                                                       kern_msg->msg_namelen,
> @@ -93,10 +93,11 @@ int verify_compat_iovec(struct msghdr *kern_msg,
> struct iovec *kern_iov,
>                         if (err < 0)
>                                 return err;
>                 }
> -               if (kern_msg->msg_name)
> -                       kern_msg->msg_name = kern_address;
> -       } else
> +               kern_msg->msg_name = kern_address;
> +       } else {
>                 kern_msg->msg_name = NULL;
> +               kern_msg->msg_namelen = 0;
> +       }
> 
>         tot_len = iov_from_user_compat_to_kern(kern_iov,
>                                           (struct compat_iovec __user
> *)kern_msg->msg_iov,
> diff --git a/net/core/iovec.c b/net/core/iovec.c
> index 827dd6b..e1ec45a 100644
> --- a/net/core/iovec.c
> +++ b/net/core/iovec.c
> @@ -39,7 +39,7 @@ int verify_iovec(struct msghdr *m, struct iovec
> *iov, struct sockaddr_storage *a
>  {
>         int size, ct, err;
> 
> -       if (m->msg_namelen) {
> +       if (m->msg_name && m->msg_namelen) {
>                 if (mode == VERIFY_READ) {
>                         void __user *namep;
>                         namep = (void __user __force *) m->msg_name;
> @@ -48,10 +48,10 @@ int verify_iovec(struct msghdr *m, struct iovec
> *iov, struct sockaddr_storage *a
>                         if (err < 0)
>                                 return err;
>                 }
> -               if (m->msg_name)
> -                       m->msg_name = address;
> +               m->msg_name = address;
>         } else {
>                 m->msg_name = NULL;
> +               m->msg_namelen = 0;
>         }
> 
>         size = m->msg_iovlen * sizeof(struct iovec);
> 
> 

LGTM! Can you send a patch?

Thanks,
Hannes
