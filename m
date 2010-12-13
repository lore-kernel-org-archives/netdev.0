From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netlink: fix gcc -Wconversion compilation warning
Date: Mon, 13 Dec 2010 13:35:25 -0800
Message-ID: <m1sjy1uzj6.fsf@fess.ebiederm.org>
References: <1292259913-9911-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Dmitry V. Levin" <ldv@altlinux.org>, linux-kernel@vger.kernel.org
To: "Kirill A. Shutsemov" <kirill@shutemov.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292259913-9911-1-git-send-email-kirill@shutemov.name> (Kirill
	A. Shutsemov's message of "Mon, 13 Dec 2010 19:05:13 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Kirill A. Shutsemov" <kirill@shutemov.name> writes:

> From: Dmitry V. Levin <ldv@altlinux.org>
>
> $ cat << EOF | gcc -Wconversion -xc -S -o/dev/null -
> unsigned f(void) {return NLMSG_HDRLEN;}
> EOF
> <stdin>: In function 'f':
> <stdin>:3:26: warning: negative integer implicitly converted to unsigned type
>
This doesn't look like a bad fix, but I believe things will fail if
we give NLMSG_ALIGN an unsigned long like size_t.  Say like sizeof.

Admittedly it has to be a huge size but still if we are going
to go fixing things...

And then there is the silliness that NLMSG_HDRLEN forces itself
to be an int, when it start out as a size_t.

So I think NLMSG_ALIGN either needs to operation exclusively
on unsigned longs aka size_t, or it needs to be type preserving.

Do you have time to look at this a bit more?


> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  include/linux/netlink.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> index 1235669..e2b9e63 100644
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -70,7 +70,7 @@ struct nlmsghdr {
>     Check		NLM_F_EXCL
>   */
>  
> -#define NLMSG_ALIGNTO	4
> +#define NLMSG_ALIGNTO	4U
>  #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
>  #define NLMSG_HDRLEN	 ((int) NLMSG_ALIGN(sizeof(struct nlmsghdr)))
>  #define NLMSG_LENGTH(len) ((len)+NLMSG_ALIGN(NLMSG_HDRLEN))
