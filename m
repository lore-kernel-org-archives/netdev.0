From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] dynamic hash table size & xor hash function for cls_fw
Date: 07 Apr 2005 07:07:35 -0400
Message-ID: <1112872055.1117.123.camel@jzny.localdomain>
References: <1112717495.1076.22.camel@jzny.localdomain>
	 <20050406143842.026B.LARK@linux.net.cn>
	 <20050406123036.GO26731@postel.suug.ch>
	 <1112794459.1096.61.camel@jzny.localdomain>
	 <20050406134502.GP26731@postel.suug.ch>
	 <20050406141020.GQ26731@postel.suug.ch>
	 <20050406111509.0462abcf.davem@davemloft.net>
	 <20050406183134.GR26731@postel.suug.ch>
	 <20050407005519.GS26731@postel.suug.ch>
	 <1112870307.1118.91.camel@jzny.localdomain>
	 <20050407105149.GT26731@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, lark@linux.net.cn,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050407105149.GT26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ok, gotcha - good idea to leave it as is..

cheers,
jamal

On Thu, 2005-04-07 at 06:51, Thomas Graf wrote:
> * jamal <1112870307.1118.91.camel@jzny.localdomain> 2005-04-07 06:38
> > On Wed, 2005-04-06 at 20:55, Thomas Graf wrote:
> > 
> > >  
> > >  static __inline__ int fw_hash(u32 handle)
> > >  {
> > > -	return handle&0xFF;
> > > +	if (HTSIZE == 4096)
> > > +		return ((handle >> 24) & 0xFFF) ^
> > > +		       ((handle >> 12) & 0xFFF) ^
> > > +		       (handle & 0xFFF);
> > > +	else if (HTSIZE == 2048)
> > > +		return ((handle >> 22) & 0x7FF) ^
> > > +		       ((handle >> 11) & 0x7FF) ^
> > > +		       (handle & 0x7FF);
> > > +	else if (HTSIZE == 1024)
> > > +		return ((handle >> 20) & 0x3FF) ^
> > > +		       ((handle >> 10) & 0x3FF) ^
> > > +		       (handle & 0x3FF);
> > > +	else if (HTSIZE == 512)
> > > +		return (handle >> 27) ^
> > > +		       ((handle >> 18) & 0x1FF) ^
> > > +		       ((handle >> 9) & 0x1FF) ^
> > > +		       (handle & 0x1FF);
> > > +	else if (HTSIZE == 256) {
> > > +		u8 *t = (u8 *) &handle;
> > > +		return t[0] ^ t[1] ^ t[2] ^ t[3];
> > > +	} else 
> > > +		return handle & (HTSIZE - 1);
> > >  }
> > 
> > Does HTSIZE change at runtime? How does migrating from one to other take
> > place? 
> 
> No, the size is static (PAGE_SIZE/sizeof(unsigned long)) (typically 1024).
> 
> > Also why not have a function pointer with a series of these being
> > separate instead of doing the if checks?
> 
> Because it is static, gcc will optimize and remove all branches leaving
> only the one that is actually needed, i.e. on most systems the hash
> function will get down to the contents of the if (HTSIZE == 1024) branch.
> 
> > BTW it does seem any one of those hashes maybe sufficient, no?
> 
> If we want to do the xor'ing to maintain collision free hashing
> for the most common case we need to separate. It would be possible
> to play games and calculate the shifts etc but gcc has a hard
> time optimizing such things.
> 
