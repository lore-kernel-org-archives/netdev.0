From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] glibc: getaddrinfo() dest. addr. selection bugfix
Date: Wed, 08 Nov 2006 14:04:07 -0800
Message-ID: <1163023447.26036.45.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, netdev@vger.kernel.org, dlstevens@us.ibm.com
Return-path: <libc-alpha-return-19529-glibc-alpha=m.gmane.org@sourceware.org>
To: libc-alpha@sourceware.org
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

While testing the default address selection support in linux, i found 
some issues in the getaddrinfo() implementation of Rule 3 and Rule 7 
in the destination address selection process as described in RFC3484.

Rule 3: Avoid deprecated addresses.
-----------------------------------
This one turned out to be a bug in getaddrinfo() routine while looking
for a matching address in the deprecated/temporary address list.
Instead of searching for the source address, the current code uses the
dest. address. The following patch fixes this issue.
=========================================================================

diff --git a/sysdeps/posix/getaddrinfo.c b/sysdeps/posix/getaddrinfo.c
--- a/sysdeps/posix/getaddrinfo.c
+++ b/sysdeps/posix/getaddrinfo.c
@@ -2085,10 +2085,12 @@ #endif
 
 		  if (q->ai_family == PF_INET6 && in6ai != NULL)
 		    {
-		      /* See whether the address is the list of deprecated
-			 or temporary addresses.  */
+		      /* See whether the source address is in the list of
+			 deprecated or temporary addresses.  */
 		      struct in6addrinfo tmp;
-		      memcpy (tmp.addr, q->ai_addr, IN6ADDRSZ);
+		      struct sockaddr_in6 *sin6p =
+			  (struct sockaddr_in6 *)&results[i].source_addr;
+		      memcpy (tmp.addr, &sin6p->sin6_addr, IN6ADDRSZ);
 
 		      struct in6addrinfo *found
 			= bsearch (&tmp, in6ai, in6ailen, sizeof (*in6ai),

============================================================================

Rule 7: Prefer native transport.
--------------------------------
I don't think checking for IFA_F_TEMPORARY flag is the right thing to do 
to figure out if we are using a tunnel transport. The temporary flag is 
used to support privacy extensions for stateless address autoconfiguration.

Instead, i think we need a way to determine if a source address belongs
to a configured tunnel link sit. Currently, the kernel doesn't provide a
flag to indicate that an address belongs to a tunnel interface. We could
add a new IFA_F_TUNNEL flag, but it requires kernel changes.

The other option is to get the interface type associated with the address.
Is there a convenient way to get device type associated with a particular 
address in the getaddrinfo code path?

Which option is preferable?

Thanks
Sridhar
