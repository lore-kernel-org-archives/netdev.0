From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Kernel 2.4.22 MLD problems
Date: Wed, 10 Dec 2003 00:22:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFFD286B8B.0DEC6335-ON88256DF8.00291E21@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE76BDFBA98B18f9e8a93df938690918c07BBE76BDFBA98B1"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Takashi Hibi <hibi665@oki.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE76BDFBA98B18f9e8a93df938690918c07BBE76BDFBA98B1
Content-type: text/plain; charset=US-ASCII





Takashi,

>But there are still some problems.
>[MLDv2]
>1. After joining multicast address, MLDv2 listener report isn't issued
immediately.

This looks like a bug; it should send the first one immediately,
and QRV-1 more at random intervals between 0 and MRC. It's adding
the MRC random delay before sending the first one. Not critical,
but I'll put a patch together in the next couple of days.

>2. After leaving multicast address, MLDv2 listener report is issued, but
multicast
> routing doesn't stop. The type of report is ChangeToIncludeMode.
> FreeBSD doesn't seem to stop multicast after receiving it.

"CHANGE_TO_INCLUDE {}" is the MLDv2 "leave group"; if FreeBSD continues
to forward them, I'm guessing that's a problem with FreeBSD, assuming
the report is well-formed. Have you tried with a FreeBSD listener?
I'd be interested in seeing packet traces if Linux and FreeBSD listeners
behave differently with the FreeBSD multicast router for this case.

>[MLDv1]
>1. After joining multicast address, MLDv2 listener report(not MLDv1) is
issued.
>  After receiving MLDv2 query, MLDv1 listener report is issued.

MLDv2 is the default. If it has received an MLDv1 query "recently", then
it'll be in "MLDv1 compatibility mode" and will answer with v1 reports,
even
for a v2 query. Leaving v1 compatibility mode is based on a timer, not on
the types of subsequent queries. So, you probably don't want to mix testing
unless you're specifically testing the v1 compatibility mode. You should
either have a v1 querier on the net, or a v2 querier, and use only that
version for the whole test. Otherwise, you can get a mix of report versions
depending on when the last v1 query was received.

I'm guessing you joined the group (v2 report scheduled) and then someone
issued a v1 query (switch to v1 compatibility mode), followed by another
(v1) report.

If you don't think there was any v1 query at that time, please do send me
a packet trace, and with the latest 2.6.0 test kernel, if possible. This
worked in my testing.

>2. After leaving multicast address, MLDv2 listener report is sometimes
issued.
>  It happens after long communication.

This is the same problem as you listed in "[MLDv2] 1)" -- there's a random
delay between reports, but the code appears to have the delay before the
first report. That's correct for a query, but not an interface state
change.

>And I have a question about recent patch.
>http://www-124.ibm.com/linux/patches/ipv6/2.4.22JUMBO.patch

This patch wasn't submitted to netdev, or the mainline-kernel. It's a
version
I created for specific testing and delivered to 2 people. You really want
the
latest mainline kernel, which has all of the patches, already integrated.

>This patch doesn't include the following patch.
>http://oss.sgi.com/archives/netdev/2003-11/msg00364.html
>Isn't it necessary?

Yes, you probably want that. Again, the latest mainline kernel tree is the
most up-to-date.

Thanks for reporting the problem, and let me know if the explanations for
the other things don't fit what you're doing (with packet traces).

                              +-DLS

--0__=07BBE76BDFBA98B18f9e8a93df938690918c07BBE76BDFBA98B1
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Takashi,<br>
<br>
<tt>&gt;But there are still some problems.<br>
&gt;[MLDv2]<br>
&gt;1. After joining multicast address, MLDv2 listener report isn't issued immediately.</tt><br>
<br>
<tt>This looks like a bug; it should send the first one immediately,</tt><br>
<tt>and QRV-1 more at random intervals between 0 and MRC. It's adding</tt><br>
<tt>the MRC random delay before sending the first one. Not critical,</tt><br>
<tt>but I'll put a patch together in the next couple of days.</tt><br>
<tt><br>
&gt;2. After leaving multicast address, MLDv2 listener report is issued, but multicast</tt><br>
<tt>&gt; routing doesn't stop. The type of report is ChangeToIncludeMode.<br>
&gt; FreeBSD doesn't seem to stop multicast after receiving it.</tt><br>
<br>
<tt>&quot;CHANGE_TO_INCLUDE {}&quot; is the MLDv2 &quot;leave group&quot;; if FreeBSD continues</tt><br>
<tt>to forward them, I'm guessing that's a problem with FreeBSD, assuming</tt><br>
<tt>the report is well-formed. Have you tried with a FreeBSD listener?</tt><br>
<tt>I'd be interested in seeing packet traces if Linux and FreeBSD listeners</tt><br>
<tt>behave differently with the FreeBSD multicast router for this case.</tt><br>
<br>
<tt>&gt;[MLDv1]<br>
&gt;1. After joining multicast address, MLDv2 listener report(not MLDv1) is issued.</tt><br>
<tt>&gt; &nbsp;After receiving MLDv2 query, MLDv1 listener report is issued.</tt><br>
<br>
<tt>MLDv2 is the default. If it has received an MLDv1 query &quot;recently&quot;, then</tt><br>
<tt>it'll be in &quot;MLDv1 compatibility mode&quot; and will answer with v1 reports, even</tt><br>
<tt>for a v2 query. Leaving v1 compatibility mode is based on a timer, not on</tt><br>
<tt>the types of subsequent queries. So, you probably don't want to mix testing</tt><br>
<tt>unless you're specifically testing the v1 compatibility mode. You should</tt><br>
<tt>either have a v1 querier on the net, or a v2 querier, and use only that</tt><br>
<tt>version for the whole test. Otherwise, you can get a mix of report versions</tt><br>
<tt>depending on when the last v1 query was received.</tt><br>
<br>
<tt>I'm guessing you joined the group (v2 report scheduled) and then someone</tt><br>
<tt>issued a v1 query (switch to v1 compatibility mode), followed by another</tt><br>
<tt>(v1) report.</tt><br>
<br>
<tt>If you don't think there was any v1 query at that time, please do send me</tt><br>
<tt>a packet trace, and with the latest 2.6.0 test kernel, if possible. This</tt><br>
<tt>worked in my testing.</tt><br>
<tt><br>
&gt;2. After leaving multicast address, MLDv2 listener report is sometimes issued.</tt><br>
<tt>&gt; &nbsp;It happens after long communication.</tt><br>
<br>
<tt>This is the same problem as you listed in &quot;[MLDv2] 1)&quot; -- there's a random</tt><br>
<tt>delay between reports, but the code appears to have the delay before the</tt><br>
<tt>first report. That's correct for a query, but not an interface state change.<br>
</tt><br>
<tt>&gt;And I have a question about recent patch.<br>
&gt;</tt><tt><a href="http://www-124.ibm.com/linux/patches/ipv6/2.4.22JUMBO.patch">http://www-124.ibm.com/linux/patches/ipv6/2.4.22JUMBO.patch</a></tt><br>
<br>
<tt>This patch wasn't submitted to netdev, or the mainline-kernel. It's a version</tt><br>
<tt>I created for specific testing and delivered to 2 people. You really want the</tt><br>
<tt>latest mainline kernel, which has all of the patches, already integrated.</tt><br>
<tt><br>
&gt;This patch doesn't include the following patch.<br>
&gt;</tt><tt><a href="http://oss.sgi.com/archives/netdev/2003-11/msg00364.html">http://oss.sgi.com/archives/netdev/2003-11/msg00364.html</a></tt><tt><br>
&gt;Isn't it necessary?<br>
</tt><br>
<tt>Yes, you probably want that. Again, the latest mainline kernel tree is the</tt><br>
<tt>most up-to-date.</tt><br>
<br>
<tt>Thanks for reporting the problem, and let me know if the explanations for</tt><br>
<tt>the other things don't fit what you're doing (with packet traces).</tt><br>
<br>
<tt>					+-DLS</tt><br>
<br>
</body></html>
--0__=07BBE76BDFBA98B18f9e8a93df938690918c07BBE76BDFBA98B1--
