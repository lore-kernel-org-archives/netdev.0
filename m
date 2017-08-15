From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 08/11] net: dsa: restore mdb dump
Date: Tue, 15 Aug 2017 10:38:22 -0700
Message-ID: <fad44e54-582d-f39b-0225-ce5fc9fcb983@gmail.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-9-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/14/2017 03:22 PM, Vivien Didelot wrote:
> The same dsa_fdb_dump_cb_t callback is used since there is no
> distinction to do between FDB and MDB entries at this layer.
> 
> Implement mv88e6xxx_port_mdb_dump so that multicast addresses associated
> to a switch port can be dumped.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 33 +++++++++++++++++++++++++--------
>  include/net/dsa.h                |  3 +++
>  2 files changed, 28 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 918d8f0fe091..2ad32734b6f6 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -1380,7 +1380,7 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
>  }
>  
>  static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
> -				      u16 fid, u16 vid, int port,
> +				      u16 fid, u16 vid, int port, bool mc,
>  				      dsa_fdb_dump_cb_t *cb, void *data)
>  {
>  	struct mv88e6xxx_atu_entry addr;
> @@ -1401,11 +1401,14 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
>  		if (addr.trunk || (addr.portvec & BIT(port)) == 0)
>  			continue;
>  
> -		if (!is_unicast_ether_addr(addr.mac))
> +		if ((is_unicast_ether_addr(addr.mac) && mc) ||

Should not this remain:

		if (!is_unicast_ether_addr(addr.mac) && mc) ||
		    (is_multicast_ether_addr(addr.mac) && !mc)

here, being:

- if this is an *not* an unicast address and MC dump is requested or
- if this is a multicast address and MC dump is not requested


-- 
Florian
