From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Fri, 14 Apr 2017 12:09:40 -0700
Message-ID: <20170414190939.GC41922@ast-mbp.thefacebook.com>
References: <20170413042036.GA46229@ast-mbp.thefacebook.com>
 <20170413.113722.2174945057832588335.davem@davemloft.net>
 <1492111341.29526.5.camel@sipsolutions.net>
 <20170413.160148.1850150011941347398.davem@davemloft.net>
 <1492157260.4735.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34685 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752080AbdDNTJp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 15:09:45 -0400
Content-Disposition: inline
In-Reply-To: <1492157260.4735.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017 at 10:07:40AM +0200, Johannes Berg wrote:
> On Thu, 2017-04-13 at 16:01 -0400, David Miller wrote:
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Date: Thu, 13 Apr 2017 21:22:21 +0200
> > 
> > > OTOH, it might depend on the frame data itself, if the program does
> > > something like
> > > 
> > > xdp->data[xdp->data[0] & 0xf]
> > > 
> > > (read or write, doesn't really matter) so then the verifier would
> > have
> > > to take the maximum possible value there into account.
> > 
> > I am not well versed enough with the verifier to understand exactly
> > how and to what extent SKB accesses are validated by the verifier.
> > 
> > My, perhaps mistaken, impression is that access range validation is
> > still at least partially done at run time.
> 
> I think you're right for SKB accesses, but I'm pretty sure that for XDP
> the verifier checks that the program can't possibly access outside of
> [xdp->data, xdp->data_end], see compare_ptrs_to_packet().
> 
> This checks that comparisons to data_end are all there, i.e. that the
> program verifies it may access some bytes before actually doing so.
> However, the program could start with
> 
> if (xdp->data_end < xdp->data + 1024)
> 	return DROP;
> [...]
> 
> and then the verifier would consider it safe.
> 
> Still, it has to track down into the [...] code to actually understand
> that it now didn't try to access xdp->data+1025, and as such it should
> be able to determine the maximum desired offset.
> 
> However, I'm coming to realize that may not necessarily mean that the
> program really *needs* to access that data.
> 
> For example, a hypothetical wifi program might want to recalculate and
> compare the CRC checksum (for whatever reason, say a driver/hardware
> bug). This would require accessing the last 4 bytes of the packet,
> which may not be present. The program could, however, accept that
> sometimes this isn't possible, and simply accept frames when it can't
> see the last 4 bytes (or if the last 4 bytes aren't the CRC because
> that isn't reported now, but whatever, I'm handwaving anyway.)
> 
> So perhaps this isn't really a good idea. The program should probably
> separately say how much data it really *needs* there, and then perhaps
> a warning could be emitted if it never accesses the data that it
> advertises as needing (i.e. if it says "I want 1024 bytes" but then
> can't possibly read more than 14)

The above descrption is correct. Also note that the offset within the packet
can be a variable as well, since that's the only way to do variable
length parsing (like ip options), so the verifier cannot tell how far
into the packet the program is going to parse. The program author cannot
tell that either!
Consider samples/bpf/parse_varlen.c:
        ihl_len = iph->ihl * 4;

        if (iph->protocol == IPPROTO_IPIP) {
                iph = data + nh_off + ihl_len;
                if (iph + 1 > data_end)
                        return 0;

'ihl' is 4 bit, so 2nd ip hdr may start at sizeof(eth) + 64 bytes,
but we cannot ask the driver to always provide these many bytes.
Technically we can add a feature to verifier to calculate the max range
into the packet that the program may look at, but it will be large.
Like if the program parses IPIP the range will be 64(first ip) + 64(second ip)
+ 64 (if it looks at tcp options).
If the program parses TLVs then the range will be 64k, so I'm not sure what
would be the value of such verifier feature.
