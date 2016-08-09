From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 9 Aug 2016 12:17:01 -0700
Message-ID: <214dcbb7-0c3b-1e00-3e50-db513d77b10b@gmail.com>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
 <57AA2001.2010904@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57AA2001.2010904@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2016 11:25 AM, Timur Tabi wrote:
> I need some help figuring that out.  Like I said, I didn't write this
> driver initially, so there are parts that I don't really understand.  I
> copied the above code from other drivers, but after studying your
> question, I think I understand what you're asking.  I just don't know
> how to fix it.
> 
> First of all, why do other drivers test MAX_SKB_FRAGS + 1?  Why the +1?

The 1 is for the non-fragment part of the SKB, like its head.

> 
> The driver originally used function emac_tx_has_enough_descs() to
> determine if there is enough room for the new packet.  Then I changed
> the code as you suggested, and now it guesses how many descriptors need
> to be free to support the next packet.

That seems fine and expected.

> 
> If I'm reading emac_tx_fill_tpd() correctly, there could be as many as
> (2 + skb_shinfo(skb)->nr_frags) descriptors for a given packet.  I don't
> know how big nr_frags could get, so I don't know how to calculate the
> number of descriptors I really need.  I'm assuming I need to do
> something like this:

nr_frags can't be bigger than MAX_SKB_FRAGS, hence these checks all
other drivers do against 1 + MAX_SKB_FRAGS.


> 
> However, I'm confused about one thing.  Almost every other driver just
> sets "netdev->mtu = new_mtu" and does nothing else.  I can't find any
> other driver that actually stops the RX path, reprograms the hardware,
> and then restarts the RX path.  I know this is a stupid question, but
> why is my driver doing that?

Most drivers allocate RX buffer sizes that are usually bigger than the
MTU, but would probably silently fail or expose transient behavior once
the MTU changes to greater than the size pre-defined.

> 
> Can I get away with just calling netdev_update_features()?

MTU change is a pretty disruptive change for the HW I typically work
with since we need to choose a RX buffer size that is aligned to the
DRAM controller burst size, reprogram the MAC to accept packets up to
that size, and potentially change the RX ring allocation strategy and
typical buffer size. None of these requirements are unusual or unique,
they ost likely apply to most MACs out there, my guess is that MTU
change is barely tested.
-- 
Florian
