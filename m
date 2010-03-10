From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [PATCH] drivers/net/tulip/eeprom.c: fix bogus "(null)" in tulip
 init messages
Date: Wed, 10 Mar 2010 20:16:37 +0100
Message-ID: <19351.61461.545790.609086@pilspetsen.it.uu.se>
References: <19351.48072.777754.465084@pilspetsen.it.uu.se>
	<20100310.084104.201710892.davem@davemloft.net>
	<1268242457.1545.347.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mikpe@it.uu.se,
	netdev@vger.kernel.org, grundler@parisc-linux.org,
	kyle@mcmartin.ca, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fanny.its.uu.se ([130.238.4.241]:47149 "EHLO fanny.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155Ab0CJTQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 14:16:47 -0500
In-Reply-To: <1268242457.1545.347.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches writes:
 > On Wed, 2010-03-10 at 08:41 -0800, David Miller wrote:
 > > From: Mikael Pettersson <mikpe@it.uu.se>
 > > Date: Wed, 10 Mar 2010 16:33:28 +0100
 > > > Booting 2.6.34-rc1 on a machine with a tulip nic I see
 > > > a number of kernel messages that include "(null)" where
 > > > previous kernels included the string "tulip0":
 > > CC:'ing the guilty party :-)  It's one of the following
 > > commits:
 > 
 > Thanks Mikael.
 > 
 > Anonymity has some good attributes.
 > Blame avoidance is one of them.
 > 
 > I've broad shoulders.  It's me, then Dwight Howard...
 > 
 > There might be another few of these where ->name or ->dev
 > was used before struct device or net_device was registered.
 > I'll go back and check.
 > 
 > tulip_core has:
 > 
 > 	if (tp->flags & HAS_MEDIA_TABLE) {
 > 		sprintf(dev->name, DRV_NAME "%d", board_idx);	/* hack */
 > 		tulip_parse_eeprom(dev);
 > 		strcpy(dev->name, "eth%d");			/* un-hack */
 > 	}
 > 
 > So I don't feel _too_ bad.
 > 
 > tulip_parse_eeprom is done before register_netdev so the logging
 > there can not use netdev_<level> or dev_<level>(&dev->dev
 > 
 > Signed-off-by: Joe Perches <joe@perches.com>
 >  drivers/net/tulip/eeprom.c |   54 ++++++++++++++++++++++++-------------------
 >  1 files changed, 30 insertions(+), 24 deletions(-)

Thanks, that fixed it:

tulip 0000:00:0f.0: enabling device (0014 -> 0017)
tulip0: EEPROM default media type Autosense
tulip0: Index #0 - Media 10baseT (#0) described by a 21142 Serial PHY (2) block
tulip0: Index #1 - Media 10baseT-FDX (#4) described by a 21142 Serial PHY (2) block
tulip0: Index #2 - Media 100baseTx (#3) described by a 21143 SYM PHY (4) block
tulip0: Index #3 - Media 100baseTx-FDX (#5) described by a 21143 SYM PHY (4) block
tulip0: Index #4 - Media 100baseTx (#3) described by a 21143 reset method (5) block
net eth0: Digital DS21142/43 Tulip rev 48 at Port 0x800, 00:00:c5:50:f9:51, IRQ 25

Tested-by: Mikael Pettersson <mikpe@it.uu.se>

 > ---
 > diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
 > index 93f4e83..49f05d1 100644
 > --- a/drivers/net/tulip/eeprom.c
 > +++ b/drivers/net/tulip/eeprom.c
 > @@ -143,6 +143,12 @@ static void __devinit tulip_build_fake_mediatable(struct tulip_private *tp)
 >  
 >  void __devinit tulip_parse_eeprom(struct net_device *dev)
 >  {
 > +	/*
 > +	  dev is not registered at this point, so logging messages can't
 > +	  use dev_<level> or netdev_<level> but dev->name is good via a
 > +	  hack in the caller
 > +	*/
 > +
 >  	/* The last media info list parsed, for multiport boards.  */
 >  	static struct mediatable *last_mediatable;
 >  	static unsigned char *last_ee_data;
 > @@ -161,15 +167,14 @@ void __devinit tulip_parse_eeprom(struct net_device *dev)
 >  		if (ee_data[0] == 0xff) {
 >  			if (last_mediatable) {
 >  				controller_index++;
 > -				dev_info(&dev->dev,
 > -					 "Controller %d of multiport board\n",
 > -					 controller_index);
 > +				pr_info("%s: Controller %d of multiport board\n",
 > +					dev->name, controller_index);
 >  				tp->mtable = last_mediatable;
 >  				ee_data = last_ee_data;
 >  				goto subsequent_board;
 >  			} else
 > -				dev_info(&dev->dev,
 > -					 "Missing EEPROM, this interface may not work correctly!\n");
 > +				pr_info("%s: Missing EEPROM, this interface may not work correctly!\n",
 > +					dev->name);
 >  			return;
 >  		}
 >  	  /* Do a fix-up based on the vendor half of the station address prefix. */
 > @@ -181,15 +186,14 @@ void __devinit tulip_parse_eeprom(struct net_device *dev)
 >  			  i++;			/* An Accton EN1207, not an outlaw Maxtech. */
 >  		  memcpy(ee_data + 26, eeprom_fixups[i].newtable,
 >  				 sizeof(eeprom_fixups[i].newtable));
 > -		  dev_info(&dev->dev,
 > -			   "Old format EEPROM on '%s' board.  Using substitute media control info\n",
 > -			   eeprom_fixups[i].name);
 > +		  pr_info("%s: Old format EEPROM on '%s' board.  Using substitute media control info\n",
 > +			  dev->name, eeprom_fixups[i].name);
 >  		  break;
 >  		}
 >  	  }
 >  	  if (eeprom_fixups[i].name == NULL) { /* No fixup found. */
 > -		  dev_info(&dev->dev,
 > -			   "Old style EEPROM with no media selection information\n");
 > +		  pr_info("%s: Old style EEPROM with no media selection information\n",
 > +			  dev->name);
 >  		return;
 >  	  }
 >  	}
 > @@ -217,8 +221,8 @@ subsequent_board:
 >  	        /* there is no phy information, don't even try to build mtable */
 >  	        if (count == 0) {
 >  			if (tulip_debug > 0)
 > -				dev_warn(&dev->dev,
 > -					 "no phy info, aborting mtable build\n");
 > +				pr_warning("%s: no phy info, aborting mtable build\n",
 > +					   dev->name);
 >  		        return;
 >  		}
 >  
 > @@ -234,8 +238,10 @@ subsequent_board:
 >  		mtable->has_nonmii = mtable->has_mii = mtable->has_reset = 0;
 >  		mtable->csr15dir = mtable->csr15val = 0;
 >  
 > -		dev_info(&dev->dev, "EEPROM default media type %s\n",
 > -			 media & 0x0800 ? "Autosense" : medianame[media & MEDIA_MASK]);
 > +		pr_info("%s: EEPROM default media type %s\n",
 > +			dev->name,
 > +			media & 0x0800 ? "Autosense"
 > +				       : medianame[media & MEDIA_MASK]);
 >  		for (i = 0; i < count; i++) {
 >  			struct medialeaf *leaf = &mtable->mleaf[i];
 >  
 > @@ -298,17 +304,17 @@ subsequent_board:
 >  			}
 >  			if (tulip_debug > 1  &&  leaf->media == 11) {
 >  				unsigned char *bp = leaf->leafdata;
 > -				dev_info(&dev->dev,
 > -					 "MII interface PHY %d, setup/reset sequences %d/%d long, capabilities %02x %02x\n",
 > -					 bp[0], bp[1], bp[2 + bp[1]*2],
 > -					 bp[5 + bp[2 + bp[1]*2]*2],
 > -					 bp[4 + bp[2 + bp[1]*2]*2]);
 > +				pr_info("%s: MII interface PHY %d, setup/reset sequences %d/%d long, capabilities %02x %02x\n",
 > +					dev->name,
 > +					bp[0], bp[1], bp[2 + bp[1]*2],
 > +					bp[5 + bp[2 + bp[1]*2]*2],
 > +					bp[4 + bp[2 + bp[1]*2]*2]);
 >  			}
 > -			dev_info(&dev->dev,
 > -				 "Index #%d - Media %s (#%d) described by a %s (%d) block\n",
 > -				 i, medianame[leaf->media & 15], leaf->media,
 > -				 leaf->type < ARRAY_SIZE(block_name) ? block_name[leaf->type] : "<unknown>",
 > -				 leaf->type);
 > +			pr_info("%s: Index #%d - Media %s (#%d) described by a %s (%d) block\n",
 > +				dev->name,
 > +				i, medianame[leaf->media & 15], leaf->media,
 > +				leaf->type < ARRAY_SIZE(block_name) ? block_name[leaf->type] : "<unknown>",
 > +				leaf->type);
 >  		}
 >  		if (new_advertise)
 >  			tp->sym_advertise = new_advertise;
 > 
 > 
