From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: oops with recent wireless-dev tree
Date: Thu, 30 Aug 2007 07:49:49 -0700
Message-ID: <20070830074949.7cd25b04@freepuppy.rosehill.hemminger.net>
References: <20070829223752.GA6969@seehuhn.de>
	<1188475530.2963.20.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, Matthew Wilcox <matthew@wil.cx>,
        netdev <netdev@vger.kernel.org>, Jochen Voss <voss@seehuhn.de>,
        linux wireless list <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1188475530.2963.20.camel@johannes.berg>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Aug 2007 14:05:30 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> Hi Jochen,
> 
> [added CCs since it affects bridge code]
> 
> > If I read this correctly, the EIP in the last line corresponds to
> > net/bridge/br_if.c, line 36:
> > 
> >     static int port_cost(struct net_device *dev)
> >     {
> > 	    if (dev->ethtool_ops->get_settings) {
> >                                ^^^^
> > 
> > As far as I can figure out, dev->ethtool_ops is NULL and the crash
> > happens while trying to derefernce ...->get_settings.
> > 
> > Is dev->ethtool_ops allowed to be NULL?  In this case the appended
> > patch might be the correct fix.  At least it makes the oops disappear
> > for me.  Another possible fix would be to add an ethtool_ops structure
> > to the device created by b43.
> 
> I don't think adding ethtool_ops in mac80211 should be necessary.
> Stephen?

Devices aren't required to have ethtool_ops. The code there used to
call ethtool directly, and it would handle the error cases. I'll rollup
a fix this morning.

The bug was introduced by this:

commit 61a44b9c4b20d40c41fd1b70a4ceb13b75ea79a4
Author: Matthew Wilcox <matthew@wil.cx>
Date:   Tue Jul 31 14:00:02 2007 -0700

    [NET]: ethtool ops are the only way
    
    During the transition to the ethtool_ops way of doing things, we supported
    calling the device's ->do_ioctl method to allow unconverted drivers to
    continue working.  Those days are long behind us, all in-tree drivers
    use the ethtool_ops way, and so we no longer need to support this.
    
    The bonding driver is the biggest beneficiary of this; it no longer
    needs to call ioctl() as a fallback if ethtool_ops aren't supported.
    
    Also put a proper copyright statement on ethtool.c.
    
    Signed-off-by: Matthew Wilcox <matthew@wil.cx>
    Signed-off-by: David S. Miller <davem@davemloft.net>

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
