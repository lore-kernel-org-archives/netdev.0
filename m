From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: Re: [PATCH 11/11] benet: Kconfig, MAINTAINETS, drivers/net Makefile
Date: Sat, 27 Dec 2008 07:41:51 -0800
Message-ID: <20081227154151.c46a87cd@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, romieu@fr.zoreil.com,
	kaber@trash.net
To: "Subbu Seetharaman" <subbus@serverengines.com>,
	"David Miller" <davem@davemloft.net>, sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:53104 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbYL0PmB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 10:42:01 -0500
In-Reply-To: 20081211114306.55826235@mailhost.serverengines.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Do you still have objection to the use of the the macros to 
calculate the offsets and shifts with the help of the pseudo 
structure ratger than defining constants ?

Thanks.

Subbu




----- Original Message -----
From: Subbu Seetharaman [mailto:subbus@serverengines.com]
To: David Miller [mailto:davem@davemloft.net], sathyap@serverengines.com
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, romieu@fr.zoreil.com, kaber@trash.net
Sent: Thu, 11 Dec 2008 03:43:06 -0800
Subject: Re: [PATCH 11/11] benet: Kconfig, MAINTAINETS, drivers/net Makefile




Thanks to everyone who reviwed and commented on the driver.

Regarding David's comments, some explation is due from us.

Unlike most other NICs, inititilizations and configuration of 
the BladeEngine NIC is done by issuing f/w commands to the 
embedded processor and not by writing / reading 
hardware registers. Most of these f/w commands involve passing
a request message with several fields of parameters and getting a
response message with a several fields.  It is best to use
structures to represent these request and response messages.
The header files that describe these structures are generated
automatically by a tool as part of the f/w build.  These
header files are used by both the drivers and f/w.  The first
version of the driver we posted had bit fields in many of these
structures and it was suggested that we get rid of bit fields.
We removed the bit fields and currently using offsets and masks 
to get and set these bit fileds.  Instead of a constant definitions
for these offsets and masks, we calculate them using the pseudo 
structures BE_XXX_AMAP where a byte (u8) represents a bit.

Regarding the abstraction, there is no separate layering here.
We use a bunch of  functions to create / destroy rings; but these
functions are Linux native.  There is some more simplifcation possible
here.

Thanks.

Subbu


----- Original Message -----
From: David Miller [mailto:davem@davemloft.net]
To: sathyap@serverengines.com
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, subbus@serverengines.com
Sent: Tue, 09 Dec 2008 22:54:53 -0800
Subject: Re: [PATCH 11/11] benet: Kconfig, MAINTAINETS, drivers/net Makefile



Ok I looked at this driver some more and I have many comments.

The hardware library abstraction has to go.  You aren't writing a
native linux driver if you split things up like this.  I know you want
code sharing with your other supported platforms, but that's too bad.
If we let every vendor do this the whole tree would be one big
unmaintainable mess.

Many structures have all-caps or capitalized names.  Good coding style
indicates that only CPP macros are to be named with capital letters.
(capital letterd symbols say to the reader "I'm a CPP macro and
probably have side-effects, beware") What's happening here looks ugly
and is inconsistent with the rest of the linux kernel.

The definition of the access to the chip registers is overly
obfuscated.  All of this structure stuff and offsetof() business
adds complexity to the driver and makes it harder to understand.

The bit twiddling is difficult to understand and makes the compiler
work too hard.

I would suggest to fix all of this by simply using macros which
define chip register offsets, and next to those offset define
macros which define the bit values within the register.  Endianness
is not an issue, and all read*()/write*() calls will write out
to the chip in little endian regardless of cpu endianness.

See other drivers such as drivers/net/tg3.[ch] or drivers/net/niu.[ch]
As you'll notice even such huge drivers as those can be done cleanly
in a single source file with no hardware abstraction library layer and
no funny register access structures and bit twiddling, so you can
strive for that as well.

So, this driver still needs a lot of work. :)

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

