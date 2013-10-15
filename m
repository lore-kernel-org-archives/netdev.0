From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Tue, 15 Oct 2013 17:03:36 +0100
Message-ID: <20131015160336.GT11739@zion.uk.xensource.com>
References: <525CAC21.5040202@oracle.com>
 <1381826609.24708.135.camel@kazak.uk.xensource.com>
 <525D0C41.2080407@oracle.com>
 <20131015100624.GB29436@zion.uk.xensource.com>
 <525D2667.6040102@oracle.com>
 <20131015125802.GR11739@zion.uk.xensource.com>
 <525D513B.70406@oracle.com>
 <20131015144910.GS11739@zion.uk.xensource.com>
 <1381848632.21901.42.camel@kazak.uk.xensource.com>
 <525D5D0E.5070107@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	ANNIE LI <annie.li@oracle.com>
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:37238 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759507Ab3JOQEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 12:04:10 -0400
Content-Disposition: inline
In-Reply-To: <525D5D0E.5070107@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 11:19:42PM +0800, jianhai luan wrote:
[...]
> >>>>
> >>>>* time_after_eq(now, next_credit) -> false
> >>>>* time_before(now, expires) -> false
> >>>If now is placed in above environment, the result will be correct
> >>>(Sending package will be not allowed until next_credit).
> >>No, it is not necessarily correct. Keep in mind that "now" wraps around,
> >>which is the issue you try to fix. You still have a window to stall your
> >>frontend.
> >Remember that time_after_eq is supposed to work even with wraparound
> >occurring, so long as the two times are less than MAX_LONG/2 apart.
> 
> Sorry for my misunderstand explanation. I mean that
>   * time_after_eq()/time_before_eq() fix the jiffies wraparound, so
> please think about  jiffies in line increasing.
>   * time_after_eq()/time_before_eq() have the range (0, MAX_LONG/2),
> the judge will be wrong if out of the range.
> 
> So please think about three kind environment
>   -  expires        now        next_credit
>      --------time increases this direction ---------->
> 
>   -  expires        [next_credit        now next_credit+MAX_LONG/2
>      --------time increase this direction ----------->
> 
>   - expires        next_credit        next_credit+MAX_LONG/2 now
>      --------time increadse this direction ---------->
> 
> The first environment should be netfront consume all credit_byte
> before next_credit, So we should pending one timer to calculator the
> new credit_byte, and don't transmit until next_credit.
> 
> the second environment should be calculator the credit_byte because
> netfront don't consume all credit_byte before next_credit, and
> time_after_eq() do correct judge.
> 
> the third environment should be calculator in time because netfront
> don't consume all credit_byte until next_credit.But time_after_eq do
> error judge (time_after_eq(now, next_credit) is false), so the
> remaining_byte isn't be increased.
> 
> and I work on the third environment.  You know now >
> next_credit+MAX_LONG/2, time_before(now, expire) should be
> true(time_before(now, expire) is false in first environment)
> >

Thanks for staighten this out for me. I'm just too dumb for this, please
be patient with me. :-)

Could you prove that time_before(now, expire) is always true in third
case? That's where my main cencern lies. Is it because msecs_to_jiffies
always returns MAX_JIFFY_OFFSET (which is ((LONG_MAX >> 1)-1) ) at most?

Wei.
