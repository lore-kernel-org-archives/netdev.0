From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [net-dsa-mv88e6xxx] question about potential use of uninitialized
 variable
Date: Thu, 11 May 2017 16:35:37 -0500
Message-ID: <20170511163537.Horde.CH1Q_6Lo2SOIbQB6MQJFV3g@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello everybody,

While looking into Coverity ID 1398130 I ran into the following piece  
of code at drivers/net/dsa/mv88e6xxx/chip.c:849:

  849static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
  850                                            struct mv88e6xxx_hw_stat *s,
  851                                            int port, u16 bank1_select,
  852                                            u16 histogram)
  853{
  854        u32 low;
  855        u32 high = 0;
  856        u16 reg = 0;
  857        int err;
  858        u64 value;
  859
  860        switch (s->type) {
  861        case STATS_TYPE_PORT:
  862                err = mv88e6xxx_port_read(chip, port, s->reg, &reg);
  863                if (err)
  864                        return UINT64_MAX;
  865
  866                low = reg;
  867                if (s->sizeof_stat == 4) {
  868                        err = mv88e6xxx_port_read(chip, port,  
s->reg + 1, &reg);
  869                        if (err)
  870                                return UINT64_MAX;
  871                        high = reg;
  872                }
  873                break;
  874        case STATS_TYPE_BANK1:
  875                reg = bank1_select;
  876                /* fall through */
  877        case STATS_TYPE_BANK0:
  878                reg |= s->reg | histogram;
  879                mv88e6xxx_g1_stats_read(chip, reg, &low);
  880                if (s->sizeof_stat == 8)
  881                        mv88e6xxx_g1_stats_read(chip, reg + 1, &high);
  882        }
  883        value = (((u64)high) << 16) | low;
  884        return value;
  885}

My question here is if there is any chance for the execution path to  
directly jump from line 860 to line 883, hence ending up using the  
uninitialized variable _low_?

I'm trying to figure out if this is a false positive or something that  
needs to be fixed.

I'd really appreciate any comment on this.

Thank you!
--
Gustavo A. R. Silva
