From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.21-rc2-mm2: drivers/net/wireless/libertas/debugfs.c addr
 bogosity
Date: Fri, 9 Mar 2007 09:14:29 -0800
Message-ID: <20070309091429.a84aee9b.randy.dunlap@oracle.com>
References: <20070306004408.d3f6434d.akpm@linux-foundation.org>
	<20070307224116.GE3441@stusta.de>
	<20070307150057.4e6342dc.akpm@linux-foundation.org>
	<20070309021146.GL4575@bakeyournoodle.com>
	<20070309141906.GA3296@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070309141906.GA3296-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Mar 2007 09:19:07 -0500 John W. Linville wrote:

> Probably should copy me and linux-wireless-u79uwXL29TaiAVqoAR/hOA@public.gmane.org  Other than
> that, this looks fine to me.  I'll queue it up shortly.
> 
> John
> 
> On Fri, Mar 09, 2007 at 01:11:46PM +1100, Tony Breeds wrote:
> > On Wed, Mar 07, 2007 at 03:00:57PM -0800, Andrew Morton wrote:
> > > On Wed, 7 Mar 2007 23:41:16 +0100
> > > Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org> wrote:
> > > 
> > > > On Tue, Mar 06, 2007 at 12:44:08AM -0800, Andrew Morton wrote:
> > > > >...
> > > > > Changes since 2.6.20-rc2-mm1:
> > > > >...
> > > > >  git-netdev-all.patch
> > > > >...
> > > > >  git trees
> > > > >...
> > > > 
> > > > drivers/net/wireless/libertas/debugfs.c contains:
> > > >   #define item_addr(n) ((u32) &((wlan_adapter *)0)->n)
> > > > 
> > > > This is wrong on 64bit architectures.
> > > 
> > > Is OK - it is simply yet another reimplementation of offsetof().  Hint.
> > 
> > Perhaps something like?
> > 
> > Against 2.6.21-rc3-mm2
> > 
> > From: Tony Breeds <tony-B47dsA4koDqXvyopL2yb9tBPR1lH4CV8@public.gmane.org>
> > 
> > Cleanup drivers/net/wireless/libertas/debugfs.c to use standard kernel macros and functions.
> > 
> > Signed-off-by: Tony Breeds <tony-B47dsA4koDqXvyopL2yb9tBPR1lH4CV8@public.gmane.org>
> > 
> > ---
> > only compile tested on x86
> > 
> >  debugfs.c |   41 ++++-------------------------------------
> >  1 file changed, 4 insertions(+), 37 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
> > index 3ad1e03..51dfd20 100644
> > --- a/drivers/net/wireless/libertas/debugfs.c
> > +++ b/drivers/net/wireless/libertas/debugfs.c
> > @@ -1772,8 +1772,8 @@ void libertas_debugfs_remove_one(wlan_private *priv)
> >  
> >  /* debug entry */
> >  
> > -#define item_size(n) (sizeof ((wlan_adapter *)0)->n)
> > -#define item_addr(n) ((u32) &((wlan_adapter *)0)->n)
> > +#define item_size(n)	(FIELD_SIZEOF(wlan_adapter, n))

Good to use FIELD_SIZEOF(), but in general, we prefer to use it
directly, not in yet another wrapper.

> > +#define item_addr(n)	(offsetof(wlan_adapter, n))
> >  
> >  struct debug_data {
> >  	char name[32];
> > @@ -1789,40 +1789,7 @@ static struct debug_data items[] = {
> >  	{"psstate", item_size(psstate), item_addr(psstate)},
> >  };
> >  
> > -static int num_of_items = sizeof(items) / sizeof(items[0]);
> > -
> > -/**
> > - *  @brief convert string to number
> > - *
> > - *  @param s   	   pointer to numbered string
> > - *  @return 	   converted number from string s
> > - */
> > -static int string_to_number(char *s)
> > -{
> > -	int r = 0;
> > -	int base = 0;
> > -
> > -	if ((strncmp(s, "0x", 2) == 0) || (strncmp(s, "0X", 2) == 0))
> > -		base = 16;
> > -	else
> > -		base = 10;
> > -
> > -	if (base == 16)
> > -		s += 2;
> > -
> > -	for (s = s; *s != 0; s++) {
> > -		if ((*s >= 48) && (*s <= 57))
> > -			r = (r * base) + (*s - 48);
> > -		else if ((*s >= 65) && (*s <= 70))
> > -			r = (r * base) + (*s - 55);
> > -		else if ((*s >= 97) && (*s <= 102))
> > -			r = (r * base) + (*s - 87);
> > -		else
> > -			break;
> > -	}
> > -
> > -	return r;
> > -}
> > +static int num_of_items = ARRAY_SIZE(items);
> >  
> >  /**
> >   *  @brief proc read function
> > @@ -1912,7 +1879,7 @@ static int wlan_debugfs_write(struct file *f, const char __user *buf,
> >  			if (!p2)
> >  				break;
> >  			p2++;
> > -			r = string_to_number(p2);
> > +			r = simple_strtoul(p2, NULL, 0);
> >  			if (d[i].size == 1)
> >  				*((u8 *) d[i].addr) = (u8) r;
> >  			else if (d[i].size == 2)



---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
