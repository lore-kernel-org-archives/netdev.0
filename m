From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] deinline a few large functions in vlan code v2
Date: Tue, 11 Apr 2006 15:17:36 +0200
Message-ID: <200604111517.37215.netdev@axxeo.de>
References: <200604071628.30486.vda@ilport.com.ua> <200604111149.24862.netdev@axxeo.de> <200604111502.52302.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Dave Dillow <dave@thedillows.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	ioe-lkml@rameria.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750821AbWDKNSF@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200604111502.52302.vda@ilport.com.ua>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Denis,

Denis Vlasenko wrote:
> On Tuesday 11 April 2006 12:49, Ingo Oeser wrote:
> > #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> > static inline  has_vlan_group(...) {
> >   /* get VLAN group */
> > }
> > #else
> > static inline  has_vlan_group(...) {return 0;}
> > #endif
> > 
> > With this and similiar changes in the drivers, 
> > your patch might be less intrusive and thus more acceptable to maintainers.
> > 
> > Just let the compiler remove the extra code with constant folding and dead
> > code elemination. The result will be even cleaner code, I think.
> > 
> > What do you think?

I thought more of introducing functions, which just fold away 
all the "if ()" blocks in normal code paths, 
which you wrapped into "#if" here. 

I don't think people have problems, if you #ifdef out complete functions,
linear setup code or structure members. People seem to have more problems
with #ifdef in control flow code, because there the condition is nothing else but
a compile time constant (the CONFIG_FOO value) which should be expressed as such.

Instead of 

#ifdef CONFIG_FOO
if (condition) {
}
#endif

just do

#ifdef CONFIG_FOO
#define foo 1
#else
#define foo 0
#endif

if  (foo && condition) {
}

Just do nothing or return a compile time constant in those inlines.

> 
> Addresses of these functions are stored into netdevice members:
>
> @@ -2549,8 +2559,10 @@ typhoon_init_one(struct pci_dev *pdev, c
>         dev->watchdog_timeo     = TX_TIMEOUT;
>         dev->get_stats          = typhoon_get_stats;
>         dev->set_mac_address    = typhoon_set_mac_address;
> +#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
>         dev->vlan_rx_register   = typhoon_vlan_rx_register;
>         dev->vlan_rx_kill_vid   = typhoon_vlan_rx_kill_vid;
> +#endif
> 
> Even empty inline would not be "optimized out to nothing" here.

No problem, just optimize out the assignment itself:

#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
static inline void typhoon_setup_vlan_hooks(struct netdev *dev) {
         dev->vlan_rx_register = typhoon_vlan_rx_register;
         dev->vlan_rx_kill_vid = typhoon_vlan_rx_kill_vid;
}
#else
static inline void typhoon_setup_vlan_hooks(struct netdev *dev) { (void)dev; }
#endif

The whole linux/if_vlan.h stuff misses this style of code.
There is simply no fallback code for CONFIG_VLAN_8021Q not being defined.


Regards

Ingo Oeser
