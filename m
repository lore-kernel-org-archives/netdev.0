From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: IPSecv6/Neighbor discovery crash
Date: Fri, 22 Aug 2003 14:55:53 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030822145553.0ca08046.kazunori@miyazawa.org>
References: <200308220149.h7M1nlAU017798@faith.austin.ibm.com>
	<20030821184640.2cb89b87.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, latten@austin.ibm.com
In-Reply-To: <20030821184640.2cb89b87.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Aug 2003 18:46:40 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Thu, 21 Aug 2003 20:49:47 -0500
> latten@austin.ibm.com wrote:
> 
> > EIP is at ndisc_build_ll_hdr+0x17/0x1e0
> 
> So what exactly is NULL in ndisc_build_ll_hdr(), is
> it 'dev'?  That'd be really weird...
> 

I had same crach.

I guess it is due to xfrm cache. My impression about the problem is likes this.

When we configure IPsec and src and dst of neighbour discoery match the configuration
occasionally, The kernel creates and caches the stackable dst like this because
ndisc_send_* want to use it

dst->output(ah6_output)
 +- child->output(ndisc_output)

Then it receives icmpv6 echo request. It replys  by using
the cached stackable dst like above. The kernel however must use another stackable dst like

dst->output(ah6_output)
 +- child->output(ip6_output)

It is the issue. The kernel can not tell first stackable dst from second stackable dst
because it can not know the last output function.

I believe we need to change the kernel to use ip6_output ( or another common output function)
to send neighbour discovery packet instead of ndisc_output essentially.

But it may make the kernel be unstable. I think there is not so much request to use IPsec
with neighbour discovery.
I think it is better to remove xfrm_lookup from ndisc_send_* functions at the moment.

Best regards,

--Kazunori Miyazawa
