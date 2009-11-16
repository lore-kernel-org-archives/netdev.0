From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Those gpio-mdio patches...
Date: Mon, 16 Nov 2009 15:25:04 -0500
Message-ID: <20091116202504.GE15157@caffeine.csclub.uwaterloo.ca>
References: <20091113.135908.249908732.davem@davemloft.net> <20091116182145.GB15157@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:55594 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753673AbZKPUY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 15:24:58 -0500
Content-Disposition: inline
In-Reply-To: <20091116182145.GB15157@caffeine.csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2009 at 01:21:45PM -0500, Lennart Sorensen wrote:
> On Fri, Nov 13, 2009 at 01:59:08PM -0800, David Miller wrote:
> > Please don't fix the issue that way.  If the routine is returning a
> > true or false value, make it return a 'bool' instead of an 'int'.
> > That way we don't have to "accept something other than 0 and 1"
> 
> Hmm.  Well I just tried to fix what was already there.  gpio-lib does
> NOT return 0 or 1, it returns 0 or 1 shifted by the gpio position in a
> gpio register, but soemthing has to convert that to a boolean value.
> Making it return a bool doesn't change the fact it needs the '!!' applied
> to make it a bool.
> 
> I can look at changing the mdio-gpio to using bool instead of integer
> where necesary.

So it looks like this would involve changing mdio-bitbang to using bool
rather than int in a couple of places.  This would affect:

./include/linux/mdio-bitbang.h
./arch/powerpc/platforms/82xx/ep8248e.c
./drivers/net/fs_enet/mii-bitbang.c
./drivers/net/phy/mdio-bitbang.c
./drivers/net/phy/mdio-gpio.c
./drivers/net/sh_eth.c

I could write up a patch for that if it makes sense.

I figure it would mean changing:

void (*set_mdc)(struct mdiobb_ctrl *ctrl, int level);
void (*set_mdio_dir)(struct mdiobb_ctrl *ctrl, int output);
void (*set_mdio_data)(struct mdiobb_ctrl *ctrl, int value);
int (*get_mdio_data)(struct mdiobb_ctrl *ctrl);

into:

void (*set_mdc)(struct mdiobb_ctrl *ctrl, bool level);
void (*set_mdio_dir)(struct mdiobb_ctrl *ctrl, bool output);
void (*set_mdio_data)(struct mdiobb_ctrl *ctrl, bool value);
bool (*get_mdio_data)(struct mdiobb_ctrl *ctrl);

Does that make sense?

Of course the only place that breaks right now is mdiobb_get_num which
assumes the value is 0 or 1.  Everywhere else appears to be fine with
0 and non-0.  Maybe putting the fix just in there or in mdiobb_get_bit
makes more sense, since then it doesn't matter what the users of
mdio-bitbang do, it will always work.

-- 
Len Sorensen
