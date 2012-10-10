From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] ip tunnel flag byte order issue
Date: Wed, 10 Oct 2012 12:06:30 -0700
Message-ID: <20121010120630.5e9f2c2c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sparse found a real problem with the ABI for tunnelling.

The SIT and VTI tunnel ioctl's both overload the i_flags field in the
ip_tunnel parameters structure. This field is defined as big endian
(be16) and the various GRE_XXX macros do the necessary byte swapping.

The problem is that both SIT and VTI are using an additional flag bit
that is defined in host byte order, and is then or'd in. It happens to
work because both possible locations hit holes in the current usage of
GRE.  For big endian cpu's it overlaps the GRE_VERSION which is always
zero, and for little endian it overlaps the GRE recursion field also
always zero.

Having the field in different places on different CPU architectures
was a mistake. The problem is fixing it will break the ABI on one or
the other architecture.  I choose to break big endian since it the
minority.

Also both VTI and SIT are overloading the same bit which is an
accident waiting to happen.  Since VTI is newer, I propose giving a
different bit to VTI.

The other alternative is keeping the same ABI, but putting a big note
as to why it works in spite of our stupidity.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/if_tunnel.h	2012-10-10 11:37:22.444050762 -0700
+++ b/include/linux/if_tunnel.h	2012-10-10 11:50:34.692168074 -0700
@@ -42,7 +42,7 @@ struct ip_tunnel_parm {
 };
 
 /* SIT-mode i_flags */
-#define	SIT_ISATAP	0x0001
+#define	SIT_ISATAP	__cpu_to_be16(0x0100)
 
 struct ip_tunnel_prl {
 	__be32			addr;
@@ -84,7 +84,7 @@ enum {
 #define IFLA_GRE_MAX	(__IFLA_GRE_MAX - 1)
 
 /* VTI-mode i_flags */
-#define VTI_ISVTI 0x0001
+#define VTI_ISVTI __cpu_to_be16(0x0200)
 
 enum {
 	IFLA_VTI_UNSPEC,
