From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Tue, 23 Aug 2016 16:49:33 -0400
Message-ID: <20160823204933.GA14311@csclub.uwaterloo.ca>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
 <20160823.094029.1244944495918162255.davem@davemloft.net>
 <1471973727.13300.162.camel@decadent.org.uk>
 <20160823.112406.549221808236512285.davem@davemloft.net>
 <20160823200941.GB2356@ZenIV.linux.org.uk>
 <1471984445.3746.129.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        David Miller <davem@davemloft.net>, ben@decadent.org.uk,
        luis.henriques@canonical.com, avijitnsec@codeaurora.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471984445.3746.129.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 23, 2016 at 01:34:05PM -0700, Joe Perches wrote:
> On Tue, 2016-08-23 at 21:09 +0100, Al Viro wrote:
> > On Tue, Aug 23, 2016 at 11:24:06AM -0700, David Miller wrote:
> > ... and then we can file a bug report against the sodding compiler.  Note
> > that
> > struct ethtool_wolinfo {
> >         __u32   cmd;
> >         __u32   supported;
> >         __u32   wolopts;
> >         __u8    sopass[SOPASS_MAX];	// 6, actually
> > };
> > is not going to *have* padding.  Not on anything even remotely sane.
> > If array of 6 char as member of a struct requires 64bit alignment on some
> > architecture, I would really like some of what the designers of that ABI
> > must have been smoking.
> 
> try this on x86-64
> 
> $ pahole -C ethtool_wolinfo vmlinux
> struct ethtool_wolinfo {
> 	__u32                      cmd;                  /*     0     4 */
> 	__u32                      supported;            /*     4     4 */
> 	__u32                      wolopts;              /*     8     4 */
> 	__u8                       sopass[6];            /*    12     6 */
> 
> 	/* size: 20, cachelines: 1, members: 4 */
> 	/* padding: 2 */
> 	/* last cacheline: 20 bytes */
> };

That would be padding after the structure elements.

I think what was meant is that it won't add padding in the middle of the
structure due to alignment, ie it isn't doing:

struct ethtool_wolinfo {
	__u32                      cmd;                  /*     0     4 */
	__u32                      supported;            /*     4     4 */
	__u32                      wolopts;              /*     8     4 */
	<4 bytes padding here>
	__u8                       sopass[6];            /*    16     6 */
};

which would have 4 bytes of padding in the middle between wolopts
and sopass.

I would not think it is the compilers job to worry about what is after
your structure elements, since you shouldn't be going there.

-- 
Len Sorensen
