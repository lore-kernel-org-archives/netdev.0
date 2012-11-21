From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Wed, 21 Nov 2012 11:42:01 +0200
Message-ID: <1353490921.6559.40.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm> <1353448728.17819.33.camel@joe-AO722>
 <20121120231930.GA27492@localhost>
 <1353454874.17819.41.camel@joe-AO722>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Rientjes" <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"Andy Whitcroft" <apw@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3060 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729Ab2KUJms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2012 04:42:48 -0500
In-Reply-To: <1353454874.17819.41.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-20 at 15:41 -0800, Joe Perches wrote:
> On Tue, 2012-11-20 at 23:19 +0000, Andy Whitcroft wrote:
> > On Tue, Nov 20, 2012 at 01:58:48PM -0800, Joe Perches wrote:
> > 
> > > +# check for multiple blank lines, warn only on the second one in a block
> > > +		if ($rawline =~ /^.\s*$/ &&
> > > +		    $prevrawline =~ /^.\s*$/ &&
> > > +		    $linenr != $last_blank_linenr + 1) {
> > > +			CHK("DOUBLE_EMPTY_LINE",
> > > +			    "One blank line separating blocks is generally sufficient\n" . $herecurr);
> > > +			$last_blank_linenr = $linenr;
> > > +		}
> > > +
> > >  # check for line continuations in quoted strings with odd counts of "
> > >  		if ($rawline =~ /\\$/ && $rawline =~ tr/"/"/ % 2) {
> > >  			WARN("LINE_CONTINUATIONS",
> > 
> > Pretty sure that will fail with combination which have removed lines.
> 
> Not as far as I can tell.
> Deleted lines followed by inserted lines seem
> to work OK.
> 
> This check is located after the test that ensures
> the current $line/$rawline is an insertion.
> 

But you do not look at the next line, so you will miss something like
that:

diff --git a/test.c b/test.c
index e3c46d4..e1c6ffc 100644
--- a/test.c
+++ b/test.c
@@ -15,7 +15,8 @@
  * something
  * something
  * something
- * next line was already empty */
+ * next line was already empty, but I'm adding another one now*/
+
 
 /* something else
  * something else

> > I have a version here which I am testing with the combinations I have
> > isolated to far ...
> 
> Enjoy.
> Can you please test my proposal against those combinations too?
> 

The way I see it, we have to handle the following cases:
a. The patch adds more than a single consecutive empty line - easy
enough, the only "problem" here is to warn only once and there are many
ways to do that.
b. The patch is adding a new empty line after an existing empty line -
for that, we must check the previous line.
c. The patch is adding a new empty line before an existing empty line -
for that, we must check the next line. If we are already checking the
next line, we can tell if this is the last empty line added and
therefore do not need to save anything in order to warn only once per
block.

My version of the patch addresses all 3 cases above, and I do not see
how we can do it without looking at the next line and the previous line
- so I think it is a valid approach.

The only identified down side is that it might fail to warn about double
empty lines if we will find a diff utility that will add the deleted
lines after the inserted lines - but even in that case, it will not
generate any annoying false positives and no other perl warnings. To
address this issue, I can add a loop that will look forward if the next
line after a newly added empty line is a deleted line, but I think this
is excessive and I will only be able to test it on manually generated
files since the diff utilities I'm familiar with are behaving nicely and
delete before adding.

Anyway, I'm looking forward for your version.

Thanks,
Eilon
