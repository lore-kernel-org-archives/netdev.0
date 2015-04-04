From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: fix filling rtable from OF description
Date: Sat, 4 Apr 2015 18:38:14 +0200
Message-ID: <20150404163814.GA19428@lunn.ch>
References: <1941340.ZSOIoOXLWB@pavel.skitlab.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Fabian Frederick <fabf@skynet.be>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1941340.ZSOIoOXLWB@pavel.skitlab.int>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel

There is the code after applying your patch:

static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
                                        struct dsa_chip_data *cd,
                                        int chip_index, int port_index,
                                        struct device_node *link)
{
        const __be32 *reg;
        int link_sw_addr;
        struct device_node *parent_sw;
        int len;

        parent_sw = of_get_parent(link);
        if (!parent_sw)
                return -EINVAL;

link is the phandle to the port in other switch. parent_sw is then the
switch property.


        reg = of_get_property(parent_sw, "reg", &len);
        if (!reg || (len != sizeof(*reg) * 2))
                return -EINVAL;

So now you get the reg property. This is documented as:

- reg                   : Describes the switch address on the MII bus


        link_sw_addr = be32_to_cpup(reg + 1);

        if (link_sw_addr >= pd->nr_chips)
                return -EINVAL;

This is now not making much sense.

Looking up the MII bus address seems wrong. You want the chip number,
not its address.

    Andrew

        /* First time routing table allocation */
        if (!cd->rtable) {
                cd->rtable = kmalloc_array(pd->nr_chips, sizeof(s8),
                                           GFP_KERNEL);
                if (!cd->rtable)
                        return -ENOMEM;

                /* default to no valid uplink/downlink */
                memset(cd->rtable, -1, pd->nr_chips * sizeof(s8));
        }

        cd->rtable[link_sw_addr] = port_index;

        return 0;
}
