From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool -E rejects magic >= 80000000
Date: Mon, 06 Jun 2011 11:23:40 +0100
Message-ID: <1307355820.2765.15.camel@bwh-desktop>
References: <4DECA785.7070207@LiPPERTEmbedded.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin Hein <MHein@LiPPERTEmbedded.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37341 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998Ab1FFKXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 06:23:44 -0400
In-Reply-To: <4DECA785.7070207@LiPPERTEmbedded.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-06 at 12:10 +0200, Jens Rottmann wrote:
> Hi,
> 
> we tripped over the fact that commands like e.g.
> 
> ethtool -E ... magic 0xCCCC8086 ...
> 
> are no longer accepted with a new Debian though the same worked on an
> ancient Slackware. Current ethtool now firmly insists on a -0x80000000
> .. +0x7FFFFFFF range for "magic", so instead of the PCI ID (usually) you
> have to provide its negative two's complement:
> 
> ethtool -E ... magic -0x33337F7A ...
> 
> This works, but is rather nonintuitive and akward.

Indeed.  I would think that the input format for the magic value on the
command line should match the output format from 'ethtool -e', except
that the magic value is never output!

> A bit of gitweb browsing led us to a commit dated 25 Jun 2010, which we
> think triggered the new behaviour:
> 
> ethtool: Parse integers into variables of different sizes and byte orders
> 
> The commit changed
> 
> { "magic", CMDL_INT, &seeprom_magic, NULL },
> ...
> case CMDL_INT: {
> 	*p = get_int(argp[i],0);
> 
> into
> 
> { "magic", CMDL_S32, &seeprom_magic, NULL },
> ...
> case CMDL_S32: {
> 	s32 *p = info[idx].wanted_val;
> 	*p = get_int_range(argp[i], 0, -0x80000000LL, 0x7fffffff);
> 
> which introduces a strict range check. The kernel sources' struct
> ethtool_eeprom defines __u32 magic, so probably ethtool's "magic" should
> be CMDL_U32 instead. (Meaning it should have been CMDL_UINT originally,
> i.e. the patch did not cause the problem, but only made it visible.)

Yes, I agree with this.

Of course, some users and scripts may now assume that this parameter is
signed.  So perhaps the range should be -0x80000000 to 0xffffffff (union
of s32 and u32 ranges)?  I'm not sure whether it's worth the trouble to
do this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

