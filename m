From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 05/12] phylib: Allow reading and writing a mii bus from
	atomic context.
Date: Wed, 16 Jun 2010 08:20:19 +0200
Message-ID: <20100616062019.GB2887@riccoc20.at.omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<1b8219e7d7993d0e8204b94e959477e3007534ce.1276615626.git.richard.cochran@omicron.at>
	<AANLkTikeae2t4KmnawOCo2LqfSI57BKjNnUayY09DfEC@mail.gmail.com>
	<20100615170806.GB10668@riccoc20.at.omicron.at>
	<AANLkTin8RI4UKzA58k_qER_urdwnD037u5GZrVQS8IoS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTin8RI4UKzA58k_qER_urdwnD037u5GZrVQS8IoS-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

> That's right, and I fully agree with that change.  To me, going back
> to allowing spin locks is a regression because it adds a new source of
> scheduling latency.

I think that the change was not about reducing scheduling
latency. Rather, the idea was simply to allow mdio bus drivers that
sleep. Here is the change log message:

    commit 35b5f6b1a82b5c586e0b24c711dc6ba944e88ef1

    PHYLIB: Locking fixes for PHY I/O potentially sleeping
    
    PHY read/write functions can potentially sleep (e.g., a PHY accessed
    via I2C).  The following changes were made to account for this:
    
        * Change spin locks to mutex locks
        * Add a BUG_ON() to phy_read() phy_write() to warn against
          calling them from an interrupt context.
        * Use work queue for PHY state machine handling since
          it can potentially sleep
        * Change phydev lock from spinlock to mutex

The fundamental issue is this: Fro the SO_TIMESTAMPING API, receive
timestamps must appear in a control message along with the packet
data. Only the MAC driver (or the PHY driver) knows how to get the
timestamp. The stack calls the MAC driver via its napi poll
function. During the call, the driver must provide the skb with Rx
timestamp.

The only reasonable way to do this is to have the driver fetch the
timestamp durng the napi poll function. For MAC drivers with fast
register access, the performance penalty is small. For PHY drivers
with must go via the MDIO bus, the performance penalty is obviously
larger, and the user must be willing to live with it.

You might suggest the alternate that the driver would defer the
netif_receive_skb() callback until a work queue completes, providing
the Rx timestamp. The driver would then call netif_receive_skb() at
some later time.

However, there are a number of problems with this idea:

1. It is really icky for the drivers to be creating new skb queues for
   this purpose. MAC drivers would have to maintain such queues on
   behalf of the PHY drivers, but only when the PHYs support
   timestamping. Yuck.

2. There is a (soft) real time constraint on the delivery of the PTP
   packets to the user space application. Basicly, delays and jitter
   in the time to receive the packet negatively affect the clock servo
   loop.

3. It cannot work for many kinds of PTP timestamping hardware. Some of
   hardware only timestamps PTP packets. That means that not every
   received packet will have a timestamp. Such hardware provides some
   key data from the packet (like PTP UUID and sequence number) with
   the timestamp. Software must match this information to a particular
   packet. In order to defer a skb, the driver must first obtain the
   timestamp information. This is a catch-22.

Having said all that, I am still open to suggestions...

Richard
