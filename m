From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: MLD problems (again)
Date: Tue, 6 Jan 2004 19:47:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB9CD4F4B.B7325416-ON88256E14.001212CD@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE487DF81945D8f9e8a93df938690918c07BBE487DF81945D"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Takashi Hibi <hibi665@oki.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE487DF81945D8f9e8a93df938690918c07BBE487DF81945D
Content-type: text/plain; charset=US-ASCII






>In some cases, both CHANGE_TO_INCLUDE and ALLOW_NEW_SOURCES can be
included.
>It is redundant. (That is why I added the code mentioned in 1) )
>When to join SSM (without previous join), is it OK to use
CHANGE_TO_INCLUDE?
>ALLOW_NEW_SOURCES seems ordinary (and Implementation of FreeBSD is so).
>I couldn't judge which should be used (or both OK) from MLDv2 draft.

We ran into something similar during testing. The problem is, I didn't
have the option of rewriting all the existing multicast code. So some
cases in the full-state interface that ought to be atomic are really a
combination of a join and a filter mode change. The reason is because
I wanted to use the existing multicast join/leave code, and leave all
the existing join/leave callers alone. That can result in an
extra change record, since it's indistinguishable from the two-step series
of joining a group and changing the filter afterwards. But (at least
with the tests we did), the report was still correct-- just not optimal.

The easy solution was to write a duplicate version of mc_join_group and
mc_leave_group, with some minor changes to them, for use by the source
filter callers and use the nearly duplicated versions for the non-source
filter callers. I chose not to do that. There is a 1-tick delay before
generating the change reports and making that longer might have the
desired effect, if all the non-atomic changes complete before the report
is sent-- I didn't try that, but it's still not guaranteed to be
atomic in the change reports.

Alternatively, the source filters (if any) could've been added as an
argument for the join and leave functions, which would've meant changing
all of the existing calls, too. I didn't like either of those approaches,
so I treated a full-state filter with auto-join as the series of join and
filter change.

I think the approach you're taking may mess up other cases, though, and
since the report isn't incorrect, just not optimal, I planned to look at
this later to see if I can think of a way around it.

>No, mld_ifc_event() is called when the problem occurrs.
>But because of the wrong mca_sfmode value, mld_send_cr() doen't
>send MLD listner report.

      If the new filter has different sources, and it should, then
it still should result in a change report. But again, I need to look
at it in more detail before suggesting a fix. When I got your initial
report, I wrote a test program and reproduced the problem, and I did
some initial looking at the code but had not yet found what's going
on; I'll get back to it this week.

                  +-DLS



--0__=07BBE487DF81945D8f9e8a93df938690918c07BBE487DF81945D
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>&gt;In some cases, both CHANGE_TO_INCLUDE and ALLOW_NEW_SOURCES can be included.<br>
&gt;It is redundant. (That is why I added the code mentioned in 1) )<br>
&gt;When to join SSM (without previous join), is it OK to use CHANGE_TO_INCLUDE?<br>
&gt;ALLOW_NEW_SOURCES seems ordinary (and Implementation of FreeBSD is so).<br>
&gt;I couldn't judge which should be used (or both OK) from MLDv2 draft.</tt><br>
<br>
<tt>We ran into something similar during testing. The problem is, I didn't</tt><br>
<tt>have the option of rewriting all the existing multicast code. So some</tt><br>
<tt>cases in the full-state interface that ought to be atomic are really a</tt><br>
<tt>combination of a join and a filter mode change. The reason is because</tt><br>
<tt>I wanted to use the existing multicast join/leave code, and leave all</tt><br>
<tt>the existing join/leave callers alone. That can result in an</tt><br>
<tt>extra change record, since it's indistinguishable from the two-step series</tt><br>
<tt>of joining a group and changing the filter afterwards. But (at least</tt><br>
<tt>with the tests we did), the report was still correct-- just not optimal.</tt><br>
<br>
<tt>The easy solution was to write a duplicate version of mc_join_group and</tt><br>
<tt>mc_leave_group, with some minor changes to them, for use by the source</tt><br>
<tt>filter callers and use the nearly duplicated versions for the non-source</tt><br>
<tt>filter callers. I chose not to do that. There is a 1-tick delay before</tt><br>
<tt>generating the change reports and making that longer might have the</tt><br>
<tt>desired effect, if all the non-atomic changes complete before the report</tt><br>
<tt>is sent-- I didn't try that, but it's still not guaranteed to be</tt><br>
<tt>atomic in the change reports.</tt><br>
<br>
<tt>Alternatively, the source filters (if any) could've been added as an</tt><br>
<tt>argument for the join and leave functions, which would've meant changing</tt><br>
<tt>all of the existing calls, too. I didn't like either of those approaches,</tt><br>
<tt>so I treated a full-state filter with auto-join as the series of join and</tt><br>
<tt>filter change.</tt><br>
<br>
<tt>I think the approach you're taking may mess up other cases, though, and</tt><br>
<tt>since the report isn't incorrect, just not optimal, I planned to look at</tt><br>
<tt>this later to see if I can think of a way around it.<br>
</tt><br>
<tt>&gt;No, mld_ifc_event() is called when the problem occurrs.<br>
&gt;But because of the wrong mca_sfmode value, mld_send_cr() doen't<br>
&gt;send MLD listner report.</tt><br>
<br>
<tt>	If the new filter has different sources, and it should, then</tt><br>
<tt>it still should result in a change report. But again, I need to look</tt><br>
<tt>at it in more detail before suggesting a fix. When I got your initial</tt><br>
<tt>report, I wrote a test program and reproduced the problem, and I did</tt><br>
<tt>some initial looking at the code but had not yet found what's going</tt><br>
<tt>on; I'll get back to it this week.</tt><br>
<br>
<tt>			+-DLS</tt><br>
<tt><br>
</tt><br>
<br>
</body></html>
--0__=07BBE487DF81945D8f9e8a93df938690918c07BBE487DF81945D--
