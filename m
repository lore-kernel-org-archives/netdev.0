From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Thu, 21 Aug 2003 02:18:32 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308210114450.1108-100000@u.domain.uli>
References: <20030820104831.6235f3b9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030820104831.6235f3b9.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 20 Aug 2003, David S. Miller wrote:

> Then people can frob the shared_media sysctl for devices
> where they want the behavior to be that we will only use
> addresses assigned to the device as the solicitor address.
>
> The shared_media setting defaults to one and thus would preserve
> current behavior by default.

	Hm, you are trying to save one additional flag :)

> The idea is not mine, Alexey suggested it to me the other day.
>
> I hope this pleases people wrt. ARP request solicitor address
> handling.

	More ideas/issues:

- can we add medium_id checks near the inet_addr_onlink check,
i.e. to extend the check for same medium, not only for same outdev,
eg. saddr and outdev can be from same medium. That means we
have to use ip_dev_find as replacement for inet_addr_type and
inet_addr_onlink

- fib_validate_source already drops packets from device with
in_dev==NULL, there is no good reason to send ARP requests.
Even ip_route_output_slow disallows such devices. That is, IP
is disabled, so and ARP.

- in the last days/weeks I have a doubt how asymmetric routing
can safely work with the default behaviour. The arp_queue can
contain packets with saddrs from different interfaces and subnets,
all to the same resolved target IP. I'm not sure the remote system
can properly answer to our requests in this case, at least, can
not do it properly without rp_filter_mask [1] if there are 2 or
more interfaces. Of course, the problem is when rp_filter is used
there.

- Broadcasting announcements for one saddr through many devices
can create problems for us if we later receive traffic for this
saddr when rp_filter=1 and there is no rp_filter_mask set. Can
someone provide example setup for asymmetric routing that relies
on the current behavior, I'll be glad to think on it.

- can we swicth to safe behavior according to the probe number?
For example, after the 1st ucast or bcast probe we can switch
to source auto selection?

[1] http://www.ssi.bg/~ja/#rp_filter_mask

Regards

--
Julian Anastasov <ja@ssi.bg>
