From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2] tcp: input header length, prediction, and timestamp
 bugs
Date: Tue, 19 Jan 2010 14:35:20 -0500
Message-ID: <4B560978.8080707@gmail.com>
References: <4B49C2D0.1070704@gmail.com> <4B50BFFC.8010108@gmail.com> <4B55ED46.40909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754711Ab0ASTf0@vger.kernel.org>
In-Reply-To: <4B55ED46.40909@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson wrote:
> Therefore, I'll resubmit this patch, removing the existing len parameter.
> And maybe *th, too....
> 
Just to quickly note that gcc 4.4 doesn't properly remember that it has
already loaded *th with this rampant use of an inline function (unlike the
older macro method):

c04ea739:	89 d3                	mov    %edx,%ebx

static inline struct tcphdr *tcp_hdr(const struct sk_buff *skb)
{
	return (struct tcphdr *)skb_transport_header(skb);
c04ea743:	8b 92 94 00 00 00    	mov    0x94(%edx),%edx
	 *
	 *	Our current scheme is not silly either but we take the
	 *	extra cost of the net_bh soft interrupt processing...
	 *	We do checksum and copy also but from device to kernel.
	 */
	if ((tcp_flag_word(tcp_hdr(skb)) & TCP_HP_BITS) == tp->pred_flags &&
...


Note that the index is in both %edx and %ebx, but it uses replaced %edx.
Although by inspection that result stays in %edx, it reloaded twice more:

	res = tcp_validate_incoming(sk, skb, tcp_hdr(skb), 1);
c04ea78c:	8b 8b 94 00 00 00    	mov    0x94(%ebx),%ecx
c04ea792:	89 da                	mov    %ebx,%edx
c04ea794:	89 f0                	mov    %esi,%eax
c04ea796:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c04ea79d:	e8 0e c3 ff ff       	call   c04e6ab0 <tcp_validate_incoming>
	if (res <= 0)
c04ea7a2:	85 c0                	test   %eax,%eax
c04ea7a4:	0f 8e 8e 03 00 00    	jle    c04eab38 <tcp_rcv_established+0x408>

#else /* NET_SKBUFF_DATA_USES_OFFSET */

static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
{
	return skb->transport_header;
c04ea7aa:	8b 83 94 00 00 00    	mov    0x94(%ebx),%eax
c04ea7b0:	f6 40 0d 10          	testb  $0x10,0xd(%eax)
c04ea7b4:	0f 85 5e 03 00 00    	jne    c04eab18 <tcp_rcv_established+0x3e8>


This doesn't happen with the parameter *th (undisturbed in %edi):

c04ea78a:	89 f9                	mov    %edi,%ecx
c04ea78c:	89 f2                	mov    %esi,%edx
c04ea78e:	89 d8                	mov    %ebx,%eax
c04ea790:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c04ea797:	e8 14 c3 ff ff       	call   c04e6ab0 <tcp_validate_incoming>
	if (res <= 0)
c04ea79c:	85 c0                	test   %eax,%eax
c04ea79e:	0f 8e 8c 03 00 00    	jle    c04eab30 <tcp_rcv_established+0x400>
		return -res;

step5:
	if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
c04ea7a4:	f6 47 0d 10          	testb  $0x10,0xd(%edi)
c04ea7a8:	0f 85 62 03 00 00    	jne    c04eab10 <tcp_rcv_established+0x3e0>


Therefore, keeping the parameter *th.
