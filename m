From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: 25 Jun 2003 13:27:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056562079.1944.1961.camel@brick.watson.ibm.com>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	 <1056547262.1945.1436.camel@brick.watson.ibm.com>
	 <1056548544.1944.1488.camel@brick.watson.ibm.com>
	 <20030625114243.F84526@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
   "David S. Miller" <davem@redhat.com>, Paul MacKerras <paulus@samba.org>,
   netdev@oss.sgi.com, fcusack@samba.org,
   "David F. Skoll" <dfs@roaringpenguin.com>,
   James Carlson <carlson@workingcode.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030625114243.F84526@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Paul:  you made an assertion to me in an eariler e-mail that you were
concerned about packet ordering for the sake of vj and compression. 
IIRC the PPPoE spec prohibits compression, probably for this very
reason. Is there any other reason we'd be worried about re-ordering in
the PPP data stream?

On Wed, 2003-06-25 at 11:45, Jamal Hadi wrote:
> 
> Have you tested the case where the ethernet card is tied to only
> CPU in SMP? That guarantees ordering.

Agreed, this does guarantee ordering.  But there are cases where I don't
have this guarantee and those are the issues Rusty's patch attempts to
solve.

> Ordering per protocol should really be that protocols problem to
> solve. If you cant solve it you have a bug.
> 

The session initiation race I described earlier is brought about
independently by several problems:

1.  PPPoE negotiation is done in user space and thus there is a window
    between completion of this negotiation and the creation of the PPPoE
    socket during which a payload packet may arrive and be dropped (SMP
    and UP).

2.  Re-ordering by softIRQ handling on SMP may cause same problem.

There's also the question as to whether or not there are other protocols
(perhaps not implemented in the kernel, but relying on AF_PACKET) may be
affected by this (#2).

We can fix #1 without any patches to core networking code.  If the SMP
softIRQ re-ordering issues is handled, then we may have some better
options for fixing #1.  But note that even if #1 is fixed and #2 isn't,
then we're not any better off. 

-- 
Michal Ostrowski <mostrows@watson.ibm.com>
