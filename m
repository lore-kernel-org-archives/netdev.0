From: Simone Piunno <pioppo@ferrara.linux.it>
Subject: Re: [PATCH] IPv6: Don't assign a same IPv6 address on a same interface (is Re: IPv6 duplicate address bugfix)
Date: Sun, 30 Mar 2003 18:36:56 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030330163656.GA18645@ferrara.linux.it>
References: <20030330122705.GA18283@ferrara.linux.it> <20030330.220829.129728506.yoshfuji@linux-ipv6.org> <20030330.235809.70243437.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, usagi@linux-ipv6.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030330.235809.70243437.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

On Sun, Mar 30, 2003 at 11:58:09PM +0900, YOSHIFUJI Hideaki wrote:

> > And, patch does not seem optimal. I'd take a look at very soon.
> 
> Here's our patch based on our fix in August, 2001.
> Question: should we use spin_lock_bh() instead of spin_lock()?

Because everywhere else in the file {read,write}_lock_bh() is used 
instead of {read,write}_lock(), so I'm assuming that _bh is required 
but I really don't know why.

Anyway I have some critics over your patch: 

 - locking inside ipv6_add_addr() is simpler and more linear but
   semantically wrong because you're unable to tell the user why his 
   "ip addr add" failed.  E.g. you answer ENOBUFS instead of EEXIST.

 - your ipv6_chk_same_addr() does a useless check for (dev != NULL)

   > +static
   > +int ipv6_chk_same_addr(const struct in6_addr *addr, struct net_device *dev)
   > +{
   > +	struct inet6_ifaddr * ifp;
   > +	u8 hash = ipv6_addr_hash(addr);
   > +
   > +	read_lock_bh(&addrconf_hash_lock);
   > +	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
   > +		if (ipv6_addr_cmp(&ifp->addr, addr) == 0) {
   > +			if (dev != NULL && ifp->idev->dev == dev)
   >  				break;
   >  		}

   your never "break" if dev == NULL, so you could return 0 before
   even acquiring the lock.

Regards,
  Simone

-- 
 Simone Piunno -- http://members.ferrara.linux.it/pioppo 
.-------  Adde parvum parvo magnus acervus erit  -------.
 Ferrara Linux Users Group - http://www.ferrara.linux.it 
 Deep Space 6, IPv6 on Linux - http://www.deepspace6.net 
 GNU Mailman, Mailing List Manager - http://www.list.org 
`-------------------------------------------------------'
