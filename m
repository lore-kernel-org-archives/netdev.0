From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCHv1 net-next] xen-netback: always fully
 coalesce guest Rx packets
Date: Mon, 19 Jan 2015 17:36:10 +0000
Message-ID: <54BD408A.6080405@citrix.com>
References: <1421157917-31333-1-git-send-email-david.vrabel@citrix.com> <20150113143033.GN4226@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Ian Campbell <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Jonathan Davies <jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:14713 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbbASRvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 12:51:31 -0500
In-Reply-To: <20150113143033.GN4226@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/15 14:30, Wei Liu wrote:
> On Tue, Jan 13, 2015 at 02:05:17PM +0000, David Vrabel wrote:
>> Always fully coalesce guest Rx packets into the minimum number of ring
>> slots.  Reducing the number of slots per packet has significant
>> performance benefits (e.g., 7.2 Gbit/s to 11 Gbit/s in an off-host
>> receive test).
>>
> 
> Good number.
> 
>> However, this does increase the number of grant ops per packet which
>> decreases performance with some workloads (intrahost VM to VM)
> 
> Do you have figures before and after this change?

Some better (more rigorous) results done by Jonathan Davies shows no
regressions with full coalescing even without the grant copy
optimization, and a big improvement to single stream receive.

                         baseline    Full coalesce
Interhost aggregate      24 Gb/s     24 Gb/s
Interhost VM receive      7.2 Gb/s   11 Gb/s
Intrahost single stream  14 Gb/s     14 Gb/s
Intrahost aggregate      34 Gb/s     34 Gb/s

We do not measure the performance of dom0 to guest traffic but my ad-hoc
measurements suggest this may be 5-10% slower.  I don't think this is a
very important use case though.

So...

>> /unless/ grant copy has been optimized for adjacent ops with the same
>> source or destination (see "grant-table: defer releasing pages
>> acquired in a grant copy"[1]).
>>
>> Do we need to retain the existing path and make the always coalesce
>> path conditional on a suitable version of Xen?

...I think the answer to this is no.

>> ---
>>  drivers/net/xen-netback/common.h  |    1 -
>>  drivers/net/xen-netback/netback.c |  106 ++-----------------------------------
>>  2 files changed, 3 insertions(+), 104 deletions(-)
> 
> Love the diffstat!

Yes, it's always nice when you delete code and it goes faster... :)

David
