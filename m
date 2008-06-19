From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
	available to userspace
Date: Thu, 19 Jun 2008 08:05:01 +0100
Message-ID: <20080619070501.GA7268@gerrit.erg.abdn.ac.uk>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806172228.06801.tomasz@grobelny.oswiecenia.net> <20080618094044.GD23684@gerrit.erg.abdn.ac.uk> <200806182246.15433.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:49474 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755267AbYFSHGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 03:06:36 -0400
Content-Disposition: inline
In-Reply-To: <200806182246.15433.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > By the way, did you notice that the matrix was incomplete - timeout
| > standalone was missing, the corrected version would look something like
| >
| Well, I assumed that you did that on purpose because that would imply that we 
| need more or less N policies for N parameters added one at a time. When we 
| want separate policy for just timeout we end up with 2^N policies. And that 
| would be just mad because the same effect can easily be achieved with setting 
| priority to the same value on all packets.
| 
No it was just forgotten. 

With regard to below, given N parameters, 2^N is the number of all
order-independent combinations of 0..N parameters. E.g. for parameters A,B,C:
 * {}                 (no parameters at all)
 * {A} {B} {C}	      (non-composite: 1 parameter)
 * {A,B} {A,C} {B,C}  (composite of N-1 parameters)	
 * {A,B,C}            (composite of N   parameters)

which gives 2^3 = 8 cases. The empty set corresponds to the "simple" policy.

| >     +-------------+--------+-------------------+------------------+
| >     | Policy Name | Policy |         Presence of Parameters       |
| >     |
| >     |             | ID#    | DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT |
| >     +-------------+--------+-------------------+------------------+
| >     | "simple     |   0    |        no         |        no        |
| >     | "prio"      |   1    |       YES         |        no        |
| >     | "timeout"   |   2?   |        no         |       YES        |
| >     | "timed-prio"|   3?   |       YES         |       YES        |
| >
| >     +-------------+--------+-------------------+------------------+
| >
| > There is a special trick for the aggregate "timed-prio" policy: it is
| > the logical-OR of the "prio" and "timeout" policy IDs. Perhaps composite
| > policy IDs could be defined in this way.
| >
| Then we would have straight mapping between possible parameters and policy 
| numbers. That is, effectively we would not set the policy number but request 
| the capability of processing certain parameters, right? So that the 
| application could specify 0, DCCP_SCM_PRIORITY, DCCP_SCM_TIMEOUT or 
| DCCP_SCM_PRIORITY|DCCP_SCM_TIMEOUT as the policy ID?
| 
I think that this would make the 2^N mentioned by you above manageable.
We only need N parameters, but gain 2^N combinations practically "for free".

But such a bottom-up approach would not necessarily make sense, since
likely the policy will do a bit more work than just reacting to the
parameters it uses, which leads to the next point.

| Could be nice, but what happens if we have two policies with the same set of 
| supported parameters? How do we differentiate them? In the above: how do we 
| diffrentiate between simple policy (which doesn't have any parameters ever) 
| and prio policy with no parameters (just because we don't need to provide any 
| for one particular case)?
We could still encode the parameters in the policy ID, by splitting the
bitmask, e.g. the low 24 bits to encode parameters, and the high 8 bits
to encode the policies using the same combination of parameters.
Numbers depend on how many different parameters/policies to support:

 * e.g. using x = 32 bits, 
 * l: lower bits  corresponding to the number of parameters
 * h: higher bits; 2^h = number of policies with same parameters

It seems h may not need to be very high. How many policies with the
same parameters should we support -- 2/4/8/16 (corresponding to	h=1/2/3/4)?
That would still leave room for up to 28 different parameters.

| > Leandro Sales de Melo has developed a DCCP plugin for gstreamer and used
| > it with VoIP/speex. It comes with example applications for these:
| > https://garage.maemo.org/frs/?group_id=297
| > https://garage.maemo.org/projects/ephone
| > http://www.mail-archive.com/dccp@vger.kernel.org/msg03101.html
| > 
| I'll have a look at these. It seems that GStreamer is the way to go. However, 
| there is a minor glitch. GStreamer doesn't support a clean way of passing 
| priority data between plugins, so the code will probably be a bit ugly.
| -- 
It is probably best to ask Leandro directly as he knows the code well and has
done a lot of work on gstreamer.
