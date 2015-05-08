From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Multiqueue pktgen and ingress path (Was: [PATCH v5 2/2] pktgen:
 introduce xmit_mode '<start_xmit|netif_receive>')
Date: Fri, 8 May 2015 17:49:27 +0200
Message-ID: <20150508174927.5b1ecdd1@redhat.com>
References: <20150507143329.8534.49710.stgit@ivy>
	<20150507143500.8534.4435.stgit@ivy>
	<554B9293.2070702@plumgrid.com>
	<554B9CDE.1050703@iogearbox.net>
	<20150508173900.3fcf78de@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/bGREVsug60aBlvyjqtYX5fI"
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39347 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752699AbbEHPty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2015 11:49:54 -0400
In-Reply-To: <20150508173900.3fcf78de@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/bGREVsug60aBlvyjqtYX5fI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Fri, 8 May 2015 17:39:00 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Thu, 07 May 2015 19:11:58 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:
> 
> > On 05/07/2015 06:28 PM, Alexei Starovoitov wrote:  
> > > On 5/7/15 7:35 AM, Jesper Dangaard Brouer wrote:  
> > >> From: Alexei Starovoitov <ast@plumgrid.com>
> > >>  
> [...snip...]
> 
> > > btw, I've started to work on a patch on top of this one that allows
> > > multiple pktgen threads to submit into the same netdev.
> > > I've used it to stress test removal of spin_lock in ingress qdisc.
> > > The idea is to add another 'name' parameter to command:
> > > 'add_device name dev'
> > > 'name' will be used to identify this pktgen thread in /proc
> > > and 'dev' used as target net_device.
> > > I think it will be useful for start_xmit testing as well.
> > > I wonder why it wasn't done earlier? The queue configuration is
> > > already supported.  
> > 
> > You mean other than below commit (iow independant of queue mapping)?
> > 
> > commit e6fce5b916cd7f7f79b2b3e53ba74bbfc1d7cf8b
> > Author: Robert Olsson <robert.olsson@its.uu.se>
> > Date:   Thu Aug 7 02:23:01 2008 -0700
> > 
> >      pktgen: multiqueue etc.  
> 
> For completeness and others reading this threads...
> 
> Pktgen multiqueue is already supported via mentioned commit, which adds
> the device naming scheme: "add_device dev@number"
> 
> And yes, the documentation does not seem to mention this.  I've been
> using it for years now... My scripts[1] take param "-t" for "threads".
> [1] https://github.com/netoptimizer/network-testing/tree/master/pktgen
> 
> I've added a more plain version of a script, based on yours, below my
> signature.

Now attached.

> The funny thing now is that scaling does not "happen" as we stall on:
>    atomic_long_inc(&skb->dev->rx_dropped);

More interesting observations with the mentioned script (now attached).

On my system the scaling stopped a 24Mpps, when I increased the number
of threads the collective scaling was stuck at 24Mpps.

Then I simply removed/compiled-out the:
 atomic_long_inc(&skb->dev->rx_dropped);

And after that change, the scaling is basically infinite/perfect.

Single thread performance increased from 24.7Mpps to 31.1Mpps, which
corresponds perfectly with the cost of an atomic operation on this HW
(8.25ns).

Diff to before:
 * (1/24700988*10^9)-(1/31170819*10^9) = 8.40292328196 ns

When increasing the threads now, they all basically run at 31Mpps.
Tried it upto 12 threads.


I'm quite puzzled why a single atomic op could "freeze" my system from
scaling beyond 24Mpps.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--MP_/bGREVsug60aBlvyjqtYX5fI
Content-Type: application/x-shellscript
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=pktgen_multiqueue01_xmit_mode.sh

IyEvYmluL2Jhc2gKZnVuY3Rpb24gcGdzZXQoKSB7CiAgICBsb2NhbCByZXN1bHQKCiAgICBlY2hv
ICQxID4gJFBHREVWCgogICAgcmVzdWx0PWBjYXQgJFBHREVWIHwgZmdyZXAgIlJlc3VsdDogT0s6
ImAKICAgIGlmIFsgIiRyZXN1bHQiID0gIiIgXTsgdGhlbgogICAgICAgIGNhdCAkUEdERVYgfCBm
Z3JlcCBSZXN1bHQ6CiAgICBmaQp9CgpbIC16ICIkMiIgXSAmJiBlY2hvICJVc2FnZTogJDAgREVW
IG51bV90aHJlYWRzIiAmJiBleGl0IDEKRVRIPSQxCk5VTV9USFJFQURTPSQyCmxldCAiTlVNX1RI
UkVBRFMgLT0gMSIKZWNobyAiTnVtYmVyIG9mIHRocmVhZHMgdG8gc3RhcnQ6ICQyICgwIHRvICRO
VU1fVEhSRUFEUykiCgojIEdlbmVyYWwgY2xlYW51cCBldmVyeXRoaW5nIHNpbmNlIGxhc3QgcnVu
ClBHREVWPS9wcm9jL25ldC9wa3RnZW4vcGdjdHJsCnBnc2V0ICJyZXNldCIKCiMgQWRkIGRldmlj
ZXMgdG8gdGhyZWFkcwojICBOb3RpY2UgdGhlIG5hbWluZyBzY2hlbWUgRVRIQE5VTQpmb3IgTlVN
IGluIGBzZXEgMCAkTlVNX1RIUkVBRFNgOyBkbwogICAgUEdERVY9L3Byb2MvbmV0L3BrdGdlbi9r
cGt0Z2VuZF8ke05VTX0KICAgIHBnc2V0ICJyZW1fZGV2aWNlX2FsbCIKICAgIHBnc2V0ICJhZGRf
ZGV2aWNlICR7RVRIfUAke05VTX0iCmRvbmUKCiMgQ29uZmlnIGVhY2ggZGV2aWNlCmZvciBOVU0g
aW4gYHNlcSAwICROVU1fVEhSRUFEU2A7IGRvCiAgICBQR0RFVj0vcHJvYy9uZXQvcGt0Z2VuLyR7
RVRIfUAke05VTX0KICAgIHBnc2V0ICJmbGFnIFFVRVVFX01BUF9DUFUiCiAgICBwZ3NldCAieG1p
dF9tb2RlIG5ldGlmX3JlY2VpdmUiCiAgICBwZ3NldCAicGt0X3NpemUgNjAiCiAgICBwZ3NldCAi
ZHN0IDE5OC4xOC4wLjQyIgogICAgcGdzZXQgImRzdF9tYWMgOTA6ZTI6YmE6NmU6YTg6ZTUiCiMg
ICAgcGdzZXQgImNvdW50IDEwMDAwMDAwMCIKICAgIHBnc2V0ICJjb3VudCAxMDAwMDAwMCIKICAg
IHBnc2V0ICJidXJzdCAzMiIKZG9uZQoKUEdERVY9L3Byb2MvbmV0L3BrdGdlbi9wZ2N0cmwKZWNo
byAiUnVubmluZy4uLiBjdHJsXkMgdG8gc3RvcCIKcGdzZXQgInN0YXJ0IgplY2hvICJEb25lIgoK
Zm9yIE5VTSBpbiBgc2VxIDAgJE5VTV9USFJFQURTYDsgZG8KICAgIGVjaG8gIkRldmljZTogJHtF
VEh9QCR7TlVNfSIKICAgIGNhdCAvcHJvYy9uZXQvcGt0Z2VuLyR7RVRIfUAke05VTX0gfCBncmVw
IC1BMiAiUmVzdWx0OiIKZG9uZQo=

--MP_/bGREVsug60aBlvyjqtYX5fI--
