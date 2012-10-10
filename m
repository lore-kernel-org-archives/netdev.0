From: Joe Perches <joe@perches.com>
Subject: Re: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 03:19:18 -0700
Message-ID: <1349864358.2386.27.camel@joe-AO722>
References: <20121010093816.GA3669@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38028 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754531Ab2JJKTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 06:19:19 -0400
In-Reply-To: <20121010093816.GA3669@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 12:42 +0300, Dan Carpenter wrote:
> "protos" is an array of unsigned longs and "i" is the number of bits in
> an unsigned long so we need to use 1UL as well to prevent the shift
> from wrapping around.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
> index a1e7601..69b5b58 100644
> --- a/drivers/isdn/i4l/isdn_ppp.c
> +++ b/drivers/isdn/i4l/isdn_ppp.c
> @@ -595,7 +595,7 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
>  			j = ipc->num / (sizeof(long) * 8);
>  			i = ipc->num % (sizeof(long) * 8);
>  			if (j < 8)
> -				protos[j] |= (0x1 << i);
> +				protos[j] |= (1UL << i);

This looks like a bitmap and probably it should use
DECLARE_BITMAP and set_bit.
Also, it looks like the set_arg size is wrong and is
a stack leak.

Maybe:

 drivers/isdn/i4l/isdn_ppp.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index a1e7601..6438d0c 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -471,7 +471,7 @@ int
 isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 {
 	unsigned long val;
-	int r, i, j;
+	int r;
 	struct ippp_struct *is;
 	isdn_net_local *lp;
 	struct isdn_ppp_comp_data data;
@@ -589,16 +589,15 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 		break;
 	case PPPIOCGCOMPRESSORS:
 	{
-		unsigned long protos[8] = {0,};
+		DECLARE_BITMAP(protos, BITS_PER_LONG * 8) = { 0, };
 		struct isdn_ppp_compressor *ipc = ipc_head;
+
 		while (ipc) {
-			j = ipc->num / (sizeof(long) * 8);
-			i = ipc->num % (sizeof(long) * 8);
-			if (j < 8)
-				protos[j] |= (0x1 << i);
+			if (ipc->num < BITS_PER_LONG * 8)
+				set_bit(ipc->num, protos);
 			ipc = ipc->next;
 		}
-		if ((r = set_arg(argp, protos, 8 * sizeof(long))))
+		if ((r = set_arg(argp, protos, sizeof(protos))))
 			return r;
 	}
 	break;
