From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH] Don't allow multiple TPGs or targets to share a portal
Date: Fri, 15 Feb 2013 07:46:28 -0800
Message-ID: <1360943188.13707.114.camel@haakon2.linux-iscsi.org>
References: <1360364708-26104-1-git-send-email-agrover@redhat.com>
	 <1360787516.13707.59.camel@haakon2.linux-iscsi.org>
	 <511C0EFD.9060702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org
To: Andy Grover <agrover@redhat.com>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <511C0EFD.9060702@redhat.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-13 at 14:09 -0800, Andy Grover wrote:
> On 02/13/2013 12:31 PM, Nicholas A. Bellinger wrote:
> > On Fri, 2013-02-08 at 15:05 -0800, Andy Grover wrote:
> >> RFC 3720 says "Each Network Portal, as utilized by a given iSCSI Node,
> >> belongs to exactly one portal group within that node." therefore
> >> iscsit_add_np should not check for existing matching portals, it should
> >> just go ahead and try to make the portal, and then kernel_bind() will
> >> return the proper error.
> >>
> >> Signed-off-by: Andy Grover <agrover@redhat.com>
> >> ---
> >
> > NACK.  Your interpretation of RFC-3720 is incorrect.  There is nothing
> > that says that a single IP address cannot be shared across multiple
> > TargetName+TargetPortalGroupTag endpoints.
> 
> A Network Portal is ip:port, not just IP. I'd agree two TPGs can use the 
> same IP as long as they listen on different ports.
> 

No.  The whole point of having IQNs is to decouple the network portal
access from the target node, so that network portals can be shared
across the network entity.  

> But that bit I quoted seems pretty clear. How should it be alternatively 
> interpreted?
> 

Your completely ignoring all the previous context to reach this
conclusion.  Consider:

3.4.  SCSI to iSCSI Concepts Mapping Model

   The following diagram shows an example of how multiple iSCSI Nodes
   (targets in this case) can coexist within the same Network Entity and
   can share Network Portals (IP addresses and TCP ports).
 
   ....

and,

3.4.1 iSCSI Architecture Model

      a)  Network Entity - represents a device or gateway that is
          accessible from the IP network.  A Network Entity must have
          one or more Network Portals (see item d), each of which can be
          used by some iSCSI Nodes (see item (b)) contained in that
          Network Entity to gain access to the IP network.

and,

      b)  iSCSI Node - 

          .....

          The separation of the iSCSI Name from the addresses used by
          and for the iSCSI node allows multiple iSCSI nodes to use the
          same addresses, and the same iSCSI node to use multiple
          addresses.

and,

Appendix D.  SendTargets Operation

   The next example has two internal iSCSI targets, each accessible via
   two different ports with different IP addresses.  The following is
   the text response:

      TargetName=iqn.1993-11.com.example:diskarray.sn.8675309
      TargetAddress=10.1.0.45:3000,1 TargetAddress=10.1.1.45:3000,2
      TargetName=iqn.1993-11.com.example:diskarray.sn.1234567
      TargetAddress=10.1.0.45:3000,1 TargetAddress=10.1.1.45:3000,2

   Both targets share both addresses; the multiple addresses are likely
   used to provide multi-path support.  The initiator may connect to
   either target name on either address.

The wording in section Section 3.4.1, e) that your referring to:

"Each Network Portal, as utilized by a given iSCSI Node, belongs to
exactly one portal group within that node."

does not mean that individual network portals are limited to a single
network entity, but that network portals are linked to a single TPG
within an individual TargetName.  Eg, 'that node' does not mean the
entire physical machine (network entity), that may contain multiple
nodes (TargetName+TargetPortalGroupTag endpoints).

However, in practice I've not yet seen a target implementation that
supports multiple TPGs actually enforce this, considering this is not
accompanied by a "SHOULD not" or "MUST not" anywhere in the spec.  So
unless you have a specific problem case where this is causing an issue
with an initiator, I'm likely not going to accept a kernel patch to
change existing behavior.

--nab
