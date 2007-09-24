From: Moni Shoua <monisonlists@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH V5 2/11] IB/ipoib: Notify the world
	before	doing unregister
Date: Mon, 24 Sep 2007 15:56:46 +0200
Message-ID: <46F7C21E.1000204@gmail.com>
References: <46F27692.3070404@voltaire.com>
	<46F2784C.9070806@voltaire.com>	<adaabrhgvfa.fsf@cisco.com>
	<46F61BF6.3000203@gmail.com> <adar6kpwdax.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adar6kpwdax.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > The action in bonding to a detach of slave is to unregister the master (see patch 10).
>  > This can't be done from the context of unregister_netdevice itself (it is protected by rtnl_lock).
> 
> I'm confused.  Your patch has:
> 
>  > +		ipoib_slave_detach(cpriv->dev);
>  >  		unregister_netdev(cpriv->dev);
> 
> And ipoib_slave_detach() is:
> 
>  > +static inline void ipoib_slave_detach(struct net_device *dev)
>  > +{
>  > +	rtnl_lock();
>  > +	netdev_slave_detach(dev);
>  > +	rtnl_unlock();
>  > +}
> 
> so you are calling netdev_slave_detach() with the rtnl lock held.
> Why can't you make the same call from the start of unregister_netdevice()?
> 
> Anyway, if the rtnl lock is a problem, can you just add the call to
> netdev_slave_detach() to unregister_netdev() before it takes the rtnl lock?
> 
>  - R.
> 

Your comment made me do a little rethinking.
In bonding, device is released by calling unregister_netdevice() that doesn't 
take the rtnl_lock (unlike unregister_netdev() that does). I guess that this made me 
confused to think that this is not possible. So, I guess I could put 
the detach notification in unregister_netedev() and the reaction to the notification 
in the bonding driver would not block.
However, I looked one more time at the code of unregister_netdevice() and found out that
nothing prevents from calling unregister_netdevice() again when the notification NETDEV_GOING_DOWN
is sent. I tried that and it works.
I have a new set of patches without sending a slave detach and I will send it soon.

Thanks for the comment Roland. It makes this patch simpler.

I'd also like to give a credit to Jay for the idea of using NETDEV_GOING_DOWN notification
instead of NETDEV_CHANGE+IFF_SLAVE_DETACH. He suggested it a while ago but I wrongly thought that
it wouldn't work.
