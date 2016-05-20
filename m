From: Petko Manolov <petkan@mip-labs.com>
Subject: Re: [PATCH] net: pegasus: remove unused variables and labels
Date: Fri, 20 May 2016 12:32:23 +0300
Message-ID: <20160520093223.GJ21813@p310>
References: <1463732595-3149399-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"xypron.glpk@gmx.de" <xypron.glpk@gmx.de>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, oneukum@suse.com, linux@roeck-us.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463732595-3149399-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guys, come on.  This code is not dead.  This code is executed every time an 
ethernet packet is received.  It takes care of various error statistics. More 
importantly, it sends the actual (reported by the adapter) packet length to the 
network layer along with the packet.

This patch removes skb_put() and netif_rx() calls and effectively kills the RX 
path.  Not to mention that the driver was not even compiled before sending the 
patch upstream.

The only sensible, although cosmetic, change would be to replace:

	if (!count || count < 4)

with

	if (count < 4)

even though GCC takes care and it optimizes away "!count" condition.

Please revert this patch before Linus pulls from the network tree.


		Petko



On 16-05-20 10:22:30, Arnd Bergmann wrote:
> The latest dead-code removal was slightly incomplete and
> left a few things behind that we now get compiler warnings
> for:
> 
> drivers/net/usb/pegasus.c: In function 'read_bulk_callback':
> drivers/net/usb/pegasus.c:475:1: error: label 'goon' defined but not used [-Werror=unused-label]
> drivers/net/usb/pegasus.c:446:8: error: unused variable 'pkt_len' [-Werror=unused-variable]
> drivers/net/usb/pegasus.c:445:6: error: unused variable 'buf' [-Werror=unused-variable]
> drivers/net/usb/pegasus.c:443:17: error: unused variable 'count' [-Werror=unused-variable]
> 
> This removes them as well.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: e00be9e4d0ff ("net: pegasus: remove dead coding")
> ---
>  drivers/net/usb/pegasus.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 1903d2e2b62d..df6d90ab7ca7 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -440,10 +440,8 @@ static void read_bulk_callback(struct urb *urb)
>  {
>  	pegasus_t *pegasus = urb->context;
>  	struct net_device *net;
> -	int rx_status, count = urb->actual_length;
> +	int rx_status;
>  	int status = urb->status;
> -	u8 *buf = urb->transfer_buffer;
> -	__u16 pkt_len;
>  
>  	if (!pegasus)
>  		return;
> @@ -472,7 +470,6 @@ static void read_bulk_callback(struct urb *urb)
>  		netif_dbg(pegasus, rx_err, net, "RX status %d\n", status);
>  	}
>  
> -goon:
>  	usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
>  			  usb_rcvbulkpipe(pegasus->usb, 1),
>  			  pegasus->rx_skb->data, PEGASUS_MTU,
> -- 
> 2.7.0
> 
> 
