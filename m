From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -stable] igbvf: integer wrapping bug
	setting the mtu
Date: Fri, 13 Sep 2013 12:54:23 +0300
Message-ID: <20130913095423.GH19256@mwanda>
References: <20130913083736.GK19211@elgon.mountain>
	<AE90C24D6B3A694183C094C60CF0A2F6026B732F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B732F@saturn3.aculab.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Sep 13, 2013 at 09:58:25AM +0100, David Laight wrote:
> > If new_mtu is very large then "new_mtu + ETH_HLEN + ETH_FCS_LEN" can
> > wrap and the check on the next line can underflow. This is one of those
> > bugs which can be triggered by the user if you have namespaces
> > configured.
> > 
> > This is a static checker fix and I'm not sure what the impact is.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
> > index 95d5430..24e3883 100644
> > --- a/drivers/net/ethernet/intel/igbvf/netdev.c
> > +++ b/drivers/net/ethernet/intel/igbvf/netdev.c
> > @@ -2342,7 +2342,7 @@ static struct net_device_stats *igbvf_get_stats(struct net_device *netdev)
> >  static int igbvf_change_mtu(struct net_device *netdev, int new_mtu)
> >  {
> >  	struct igbvf_adapter *adapter = netdev_priv(netdev);
> > -	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
> > +	unsigned int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
> > 
> >  	if ((new_mtu < 68) || (max_frame > MAX_JUMBO_FRAME_SIZE)) {
> >  		dev_err(&adapter->pdev->dev, "Invalid MTU setting\n");
> 
> It is safer to check:
>   	if ((new_mtu < 68) || (new_mtu > MAX_JUMBO_FRAME_SIZE - ETH_HLEN - ETH_FCS_LEN)) {
> 

I believe my fix is already 100% safe...  Where is the bug in my code?

Your fix harder to read because of the additional math and because it's
checking "new_mtu" when we care about "max_frame".

regards,
dan carpenter


------------------------------------------------------------------------------
How ServiceNow helps IT people transform IT departments:
1. Consolidate legacy IT systems to a single system of record for IT
2. Standardize and globalize service processes across IT
3. Implement zero-touch automation to replace manual, redundant tasks
http://pubads.g.doubleclick.net/gampad/clk?id=51271111&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
