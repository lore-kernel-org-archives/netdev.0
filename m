From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPv6 oops on ifup in latest BK
Date: Mon, 23 Aug 2004 23:51:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823235123.71f18c04.davem@redhat.com>
References: <412ADB20.5000901@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <412ADB20.5000901@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 02:07:28 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Attached minicom.cap.txt gives the ksymoops output and dmesg output. 
> Appears to die in ipv6_get_hoplimit.

Yoshifuji-san, it is rt6i_dev changes.  The problem is that
ipv6_get_hoplimit() gets called with NULL dev.

I believe it is an error in the logic for RTCF_REJECT
processing.  If user does not specify a specific device
index, and this is RTCF_REJECT, then we will end up
with dev being NULL.

It is this piece of code in ip6_route_add():

		if (dev && dev != &loopback_dev) {

It does not handle the case where dev == NULL correctly.
Original code did do the right thing:

		if (dev)
			dev_put(dev);
		dev = &loopback_dev;
		dev_hold(dev);

Maybe new code should be something like:

		if (dev && dev != &loopback_dev) {
			dev_put(dev);
			in6_dev_put(idev);
		}
		dev = &loopback_dev;
		dev_hold(dev);
		idev = in6_dev_get(dev);
		if (!idev) {
			err = -ENODEV;
			goto out;
		}

What do you think?
