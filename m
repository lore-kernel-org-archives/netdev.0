From: James Morris <jmorris@namei.org>
Subject: Re: [RFC 0/4] NetLabel
Date: Thu, 25 May 2006 20:06:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605251938360.27473@d.namei>
References: <44760E29.4070407@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <44760E29.4070407@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006, Paul Moore wrote:

> This patch introduces a new kernel feature designed to support labeled
> networking protocols such as RIPSO and CIPSO.  These protocols are required to
> interoperate with existing "trusted" operating systems such as Trusted
> Solaris.

A few initial comments.

- Did you decide that you definitely need to verify labels on fragments?  

I can see the code's been added to do that, but wonder about a comment 
made during earlier discussion that mislabeled fragments could only come 
from a misbehaving trusted system.  What is the threat model here?


- Can you explain how module loading and module refcounting for these 
modules work?  (e.g. what causes netlabel_cipso_v4 to be loaded, is it 
always safe to unload if the refcount is zero?)


- What about user APIs for setting and retrieving labels?


- What about labeling of kernel-generated packets?


- Don't put #ifdef'd code into mainline code.

e.g. in net/ipv4/ip_fragment.c

+#ifdef CONFIG_NETLABEL_CIPSOV4
+       if (sopt->cipso) {

This needs to be a function which is compiled away as a static inline when 
not selected.  This stuff should have zero impact on the networking code 
if not enabled.


- Try and add entries for security/selinux/nlmsgtab.c for the new Netlink 
protocol.


- This does not follow normal kernel coding practices:

+       if (netlbl_netlink_init() != 0) {
+               netlbl_domhsh_exit();
+               return -ENOMEM;

This should be:

{
	err = netlbl_netlink_init();
	if (err)
		goto err_domhsh;

	...

err_domhsh:
	netlbl_domhsh_exit();
	return err;
}

i.e. a single error path when you have cleanups to perform, and 
propagation of error codes.


- This kind of stuff should be removed before merging:

+static void __exit netlbl_exit(void)
+{
+       printk(KERN_INFO "NetLabel: Exiting\n");


+int netlbl_netlink_init(void)
+{
+       BUG_ON(netlbl_nl);


+int netlbl_netlink_exit(void)
+{
+       BUG_ON(!netlbl_nl);


Should the above two be marked __init and __exit?  And why does the last 
one return an int when the only possible return value is zero?  (it needs 
to return void).


- Why does this module have a version number?

+       printk(KERN_INFO "NetLabel: Initializing (v%s %s)\n",
+              NETLBL_VER_STR, NETLBL_VER_DATE);





-- 
James Morris
<jmorris@namei.org>
