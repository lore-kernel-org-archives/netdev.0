From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 6/6] drivers/net/pppol2tp.c: remove null pointer dereference
Date: Mon, 12 May 2008 18:12:38 +0100
Message-ID: <48287A86.1070401@katalix.com>
References: <Pine.LNX.4.64.0805121538510.3694@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757522AbYELRMw@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0805121538510.3694@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding netdev to CC list.

Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> If session is NULL, it is not possible to access its name field.  So I have
> split apart the printing of the error message to drop the printing of the
> name field in this case.

I suggest add a note in the patch description that this bug will only be 
hit if the driver's debug is enabled.

> This problem was found using the following semantic match
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @@
> expression E, E1;
> identifier f;
> statement S1,S2,S3;
> @@
> 
> * if (E == NULL)
> {
>   ... when != if (E == NULL) S1 else S2
>       when != E = E1
> * E->f
>   ... when any
>   return ...;
> }
> else S3
> // </smpl>

Perhaps the above text should be in the additional info section of the 
patch description?

Since this is a network driver, can you resubmit the patch to netdev?

> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
> 
> diff -u -p a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
> --- linux-2.6/drivers/net/pppol2tp.c	2008-05-09 16:46:57.000000000 +0200
> +++ linuxcopy/drivers/net/pppol2tp.c	2008-05-12 15:30:52.000000000 +0200
> @@ -1621,9 +1621,16 @@ out_no_ppp:
>  end:
>  	release_sock(sk);
>  
> -	if (error != 0)
> -		PRINTK(session ? session->debug : -1, PPPOL2TP_MSG_CONTROL, KERN_WARNING,
> -		       "%s: connect failed: %d\n", session->name, error);
> +	if (error != 0) {
> +		if (session)
> +			PRINTK(session->debug,
> +				PPPOL2TP_MSG_CONTROL, KERN_WARNING,
> +				"%s: connect failed: %d\n",
> +				session->name, error);
> +		else
> +			PRINTK(-1, PPPOL2TP_MSG_CONTROL, KERN_WARNING,
> +				"connect failed: %d\n", error);
> +	}
>  
>  	return error;
>  }
> 
