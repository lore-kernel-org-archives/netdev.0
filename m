From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH/RFC] enabling netdev boot options
Date: Sat, 8 Nov 2003 17:03:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031108170342.78548c86.rddunlap@osdl.org>
References: <20031108160416.236ec29d.rddunlap@osdl.org>
	<20031108162248.5846ab46.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, saw@saw.sw.com.sg
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031108162248.5846ab46.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 8 Nov 2003 16:22:48 -0800 Andrew Morton <akpm@osdl.org> wrote:

| "Randy.Dunlap" <rddunlap@osdl.org> wrote:
| >
| > 
| > I have modified 3c59x.c (for 2.4.22 and 2.6.0-test9) and eepro100
| > (for 2.6.0-test9 only) to check for netdev= boot options.
| 
| A worthy project, thanks.
| 
| > +	rtnl_lock();
| > +
| > +	retval = dev_alloc_name(dev, dev->name);
| > +	if (retval < 0)
| > +		goto err_free_unlock;
| > +
| > +	rtnl_unlock();
| 
| It would be better to move this locking into the core net layer. 
| Call dev_alloc_name_which_takes_rtnl_lock() here ;)

Makes sense, but I'm wary of some drivers which do rtnl_lock()
early and hold it for long times (like eepro100).
Methinks that it shouldn't do that, but that's a different patch.

| > @@ -1351,8 +1362,10 @@ free_ring:
| >  free_region:
| >  	if (vp->must_free_region)
| >  		release_region(ioaddr, vci->io_size);
| > -	kfree (dev);
| > +err_free_unlock:
| >  	printk(KERN_ERR PFX "vortex_probe1 fails.  Returns %d\n", retval);
| > +	rtnl_unlock();
| > +	kfree (dev);
| >  out:
| >  	return retval;
| >  }
| 
| This causes an rtnl_unlock() imbalance if vortex_probe1() takes the
| `goto free_region' path, does it not??

I'll check that again.  Might be right.

--
~Randy
