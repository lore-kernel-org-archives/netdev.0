From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: suggested forcedeth updates....
Date: Thu, 20 Nov 2003 18:04:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031120180428.B1538@sygehus.dk>
References: <BAY2-F153s0m7nz605N0001807b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexander Zapatka <alexzapatka@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY2-F153s0m7nz605N0001807b@hotmail.com>; from alexzapatka@hotmail.com on Wed, Nov 19, 2003 at 10:06:13AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2003 at 10:06:13AM -0500, Alexander Zapatka wrote:
> thats a great idea!  except i dont know how to implement it in a patch :)  
> hope it makes it in to the next version.

It is fairly simple. In the driver private structure, add a field named
"msg_enable". In the probe function (the one where alloc_etherdev() is
called), set the msg_enable field from the global debug variable. Then,
use the macros from linux/netdevice.h to see if the debug output should be
printed. For example:

void forcedeth_init_one (stuff)
{
	struct forcedeth_private *fp;
	...
	dev = alloc_etherdev (sizeof (struct forcedeth_private));
	...
	fp = dev->priv;
	fp->msg_enable = debug;
	...
	register_netdev (dev);
}

void forcedeth_rx_one (stuff)
{
	struct forcedeth_private *fp = dev->priv;

	if (unlikely (netif_msg_rx_data (fp))) {
		printk_packet_data ();
	}
}

And so on. In some cases you may not have a dev and thus no dev->priv and
need to use the NETIF_MSG_* flags directly, e.g.

	if (debug & NETIF_MSG_HW)
		dump_registers();

but I think that will only happen early in the probe function.

Then there is the ethtool part. This used to involve a lots of ioctl() grot
in every driver that wanted to be ethtool capable, but have a look at the
dev->ethtool_ops patches posted recently, as they should simplify things a lot.

-- 
Regards,
Rask Ingemann Lambertsen
