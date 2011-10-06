From: "Jan Beulich" <JBeulich@suse.com>
Subject: __net_exit bogusly defined as __exit_refok ?
Date: Thu, 06 Oct 2011 12:55:23 +0100
Message-ID: <4E8DB34B0200007800059AA5@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Realizing that this has been this way a for a rather long time, I still wonder
why it was done that way: __exit_refok (evaluating to __ref) allows these
functions to reference __init functions and __initdata objects (which is
wrong, since those can get called in the context of __exit code, at which
point .init.* sections are already gone).

Second, __exit_refok results in the code to not be discarded at all
(with the original patch's description wrongly indicating that without
NET_NS the exit functions would never be called - they get called from
unregister_pernet_operations(), which generally gets invoked from
modules' __exit sections), which is the same as if no section
placement annotation was present.

Thus, rather than being the only user of __exit_refok (which by itself
is a dubious construct), it would seem to make more sense to make
__net_exit resolve to nothingregardless of NET_NS  (short of going
through the code and remove all uses of it) and delete __exit_refok.

One alternative might be to make __net_exit at least resolve to
__init_or_module, as __exit functions won't be called without
MODULES. Or really, you'd want something that resolves to __init
when built into the kernel, and to nothing when built as a module.
Both, however, would require some adjustments to modpost's
section mismatch checking.

Jan
