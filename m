From: James Morris <jmorris@intercode.com.au>
Subject: Re: IPSec: setkey -DP freezes machine
Date: Sat, 1 Mar 2003 03:01:04 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303010205360.27480-100000@blackbird.intercode.com.au>
References: <OF2046BAB2.15FCD4CE-ON86256CDA.006CD0E3-86256CDA.0078C74D@pok.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tom Lendacky <toml@us.ibm.com>
In-Reply-To: <OF2046BAB2.15FCD4CE-ON86256CDA.006CD0E3-86256CDA.0078C74D@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Feb 2003, Tom Lendacky wrote:

> So for the fix, would it be preferable to have the xfrm_policy family
> always be assigned the socket family value or should it retain the current
> setting and only be set to the socket family value if the current value is
> 0 (AF_UNSPEC)?

The first may be necessary, as the family field is needed along the
following path:

pfkey_compile_policy()
 -> parse_ipsecrequests()
   -> parse_ipsecrequest() {
              ... 
              if (t->mode) {
                      switch (xp->family) {
    
               ...
      }

In the code snippet above, xp->family will be zero as xp was allocated in 
pfkey_compile_policy() and not set after being zeroed.

This is assuming we want to be able to set tunnel mode on a socket (which
is supported in some implementations e.g. Solaris, and can be very
useful).

If so, it would be good if we could make use of half of the
sadb_x_policy_reserved2 field to carry the socket family value, and copy
it during pfkey_compile_policy().

Alternatively, a family parameter could be added to the compile_policy() 
operation, but this duplicates data already present in our native 
xfrm_userpolicy_info format.


- James
-- 
James Morris
<jmorris@intercode.com.au>
