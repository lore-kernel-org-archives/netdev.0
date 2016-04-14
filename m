From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/8] dsa: mv88e6xxx: Prepare for turning this
 into a library module
Date: Thu, 14 Apr 2016 14:26:39 -0700
Message-ID: <57100B0F.4040909@gmail.com>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
 <1460591998-20598-2-git-send-email-andrew@lunn.ch>
 <874mb454b3.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33417 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbcDNV2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 17:28:45 -0400
Received: by mail-pf0-f178.google.com with SMTP id 184so49807644pff.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 14:28:45 -0700 (PDT)
In-Reply-To: <874mb454b3.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/04/16 13:22, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
>> Export all the functions so that we can later turn the module into a
>> library module.
>>
>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> 
> Sorry but I don't like this. We don't want one module per 88E6xxx switch
> model. We need one driver supporting them all, like any other driver.

Are you sure this is a good model moving forward? This means the library
needs to know about every new switch added and all its little gory
details, whereas the point is that it represents *most* of what is
needed, defines a good enough, generic model, but does not have to deal
(too much) with HW-specifics, see below.

> 
> Multiple modules will continue to confuse us with duplicated code. For
> instance, every specific mv88e6*_setup_global functions program the
> switch's DSA device number with something like:
> 
>     REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL_2, ds->index & 0x1f);
> 
> Looking at every drivers/net/dsa/mv88e6*.c file, there are only few
> differences in their dsa_switch_driver structures:
> 
> The .setup function is always specific, but easily factorizable in a
> mv88e6xxx_setup function. The .probe function can be merged once we have
> a single driver. mv88e6131 has different phy_{read,write} functions
> which can be abstracted in mv88e6xxx_phy_{read,write}. Only mv88e6352
> has support for the EEPROM, which is simple to abstract too.
> 
> I'm working on a few patches right away to factorize this and lighten up
> that part from your current refactoring of DSA.
> 
> Here's an example of duplicated code fixed for the 6131 PHY access code:
> 
>     http://ix.io/wJm

The cost of maintaining a smallish piece of driver code that deals with
things that are extremely specific to a given switch HW seems like a
reasonable thing to do. The library should ideally be mostly
HW-independent in the sense that it should only deal with switch HW
properties that are shared and common (number of ports, number of
FIB/VTUs etc.) and the indidivual switch drivers need to deal with all
the ad-hoc stuff that has no place everywhere else.

I believe this is currently the case for most of what is being done by
mv88e6xxx.c, Andrew's patches are not making things worse.
-- 
Florian
