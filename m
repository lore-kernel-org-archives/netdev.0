From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: "ss -p" segfaults
Date: Thu, 16 Jul 2015 01:22:38 +0300
Message-ID: <20150715222238.GA13019@angus-think.lan>
References: <2282663.K45lFmE7Zp@fb07-iapwap2>
 <20150715151204.GB28525@angus-think.wlc.globallogic.com>
 <E7D9D05A-8C76-43A4-AF2F-B64C27E6C20B@intel.com>
 <C873AEFC-4840-4651-8AE3-F9D21DDDD0DA@intel.com>
 <20150715185751.GA19820@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, Marc Dietrich <marvin24@gmx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:34293 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbbGOWYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 18:24:38 -0400
Received: by wibud3 with SMTP id ud3so831575wib.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 15:24:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150715185751.GA19820@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 09:57:51PM +0300, Vadim Kochan wrote:
> On Wed, Jul 15, 2015 at 06:52:49PM +0000, Rustad, Mark D wrote:
> > > On Jul 15, 2015, at 9:49 AM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
> > > 
> > >> On Jul 15, 2015, at 8:12 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> > >> Would you please check this fix ?
> > >> 
> > >> diff --git a/misc/ss.c b/misc/ss.c
> > >> index 03f92fa..3a826e4 100644
> > >> --- a/misc/ss.c
> > >> +++ b/misc/ss.c
> > >> @@ -683,8 +683,8 @@ static inline void sock_addr_set_str(inet_prefix *prefix, char **ptr)
> > >> 
> > >> static inline char *sock_addr_get_str(const inet_prefix *prefix)
> > >> {
> > >> -    char *tmp ;
> > >> -    memcpy(&tmp, prefix->data, sizeof(char *));
> > >> +    char *tmp;
> > >> +    memcpy(&tmp, &prefix->data[0], sizeof(char *));
> > >>    return tmp;
> > >> }
> > > 
> > > That surely is not a fix! The destination of the memcpy is the address of an uninitialized stack variable! Both versions are equally bad.
> > 
> > I probably over-reacted, but using memcpy to access a pointer in this way is just ugly. For one thing, it circumvents any sanity-checking that the compiler can do. And changing the prefix->data to &prefix->data[0] should be exactly the same thing and therefore should not fix anything. Anyway, never mind that.
> > 
> > Looking at more of the code, it looks to me like the the string pointer in data can sometimes point to a literal string instead of allocated memory when proc is in use. Free would not be happy with that. Look at the use of variable peer in function unix_stats_print.
> > 
> Yes that right, I am already looking on this ...
> > --
> > Mark Rustad, Networking Division, Intel Corporation
> > 

I did partially revert of the buggy commit and it does not crash, but I will do
more testing, and after will send the patch and will try to prepare some
test scripts for ss.

The crash appears only if to dump processes info from /proc, which might
be caused that netlink stats returned error, probably by wrong request
(not supported attribute or flag ?).
