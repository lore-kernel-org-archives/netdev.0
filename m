From: Donald Becker <becker@scyld.com>
Subject: Re: looking for help with scanning of IPv6 interfaces
Date: Fri, 15 Nov 2002 17:46:55 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211151737010.6439-100000@beohost.scyld.com>
References: <20021115200051.A14677@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michael Richardson <mcr@sandelman.ottawa.on.ca>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20021115200051.A14677@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Nov 2002, Andi Kleen wrote:
> On Fri, Nov 15, 2002 at 12:38:12PM -0500, Michael Richardson wrote:
> > 1) Awhile ago there was a flame war about using SIOCGIFCONF/SIOCGLIFCONF
> > to get lists of interfaces. This was suggested as being a bad way.
...
> > Marc Andrews, sitting next to me, asked if I knew what the offical magic
> > was. Can someone point me that officially blessed way to do this?

Here is a comment and our standard snippet of code to do this:
________________
    char linebuf[400];	/* Max possible line is 192 chars. */
    FILE *fp;
    int ifnum;

    /* Yes, the only list of physical network interfaces is /proc/net/dev.
     * Through 2.4.19, there is no other way to get 'dev_base' from the
     * kernel.  The ioctl(..SIOCGIFCONF..) call comes closes, but only
     * returns a value for interfaces once assigned a protocol address.
     */
    fp = fopen("/proc/net/dev", "r");
    if (fp == NULL) {
	fprintf(stderr, "Failed to open /proc/net/dev.\n");
	return 0;
    }

    /* The format of /proc/net/dev is "%6s:%8lu ..." */

    ifnum = 0;
    while (fgets(linebuf, sizeof linebuf, fp) && (ifnum < max_numifs)) {
	struct ifreq ifr, ifrq_index, ifrq_hwaddr;
	char *p, *ifname;
	int flags;

	/* This is approximately sscanf(linebuf, "%s:", ifnamebuf). */
	p = index(linebuf, ':');
	if (!p) continue;
	*p = 0;
	/* Skip leading space. */
	for (ifname = linebuf; isspace(*ifname); ifname++)
	    ;

	strncpy(ifr.ifr_name, ifname, sizeof ifr.ifr_name);
	/* Get the interface flags */
	if (ioctl(sockfd, SIOCGIFFLAGS, &ifr)) {
	    fprintf(stderr, "Failed to get information about network "
		    "interface %s.\n   SIOCGIFFLAGS: %s\n", 
		    ifname, strerror(errno));
	    continue;
	}
	if (ifr.ifr_flags & IFF_LOOPBACK)
	    continue;
	flags = ifr.ifr_flags;

	strncpy(ifrq_index.ifr_name, ifname, sizeof ifr.ifr_name);
	strncpy(ifrq_hwaddr.ifr_name, ifname, sizeof ifr.ifr_name);
	if (ioctl(sockfd, SIOCGIFINDEX, &ifrq_index) < 0
	    || ioctl(sockfd, SIOCGIFHWADDR, &ifrq_hwaddr) < 0 ) {
	    fprintf(stderr, "Failed to get address information for network "
		    "interface %s: %s\n", 
		    ifname, strerror(errno));
	}
________________

> Physical devices are read using /proc/net/dev
...
> That is the old fashioned way.
>  
> The new fashioned one is to query them using rtnetlink. You use a RTM_GETADDR
> NLM_F_REQUEST query with wildcard (NLM_F_ROOT) to get a full list.
> See the netlink,rtnetlink, libnetlink manpages and iproute2 as an example. 
> It is easier when you use libnetlink.

Do you have a snippet of code?
What kernel version does this start working?

Of course for code that needs to work with already deployed systems, you
need to have code for the old method around anyway...

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
