From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: Re: [net-next RFC 0/4] SO_BINDTOSUBNET
Date: Mon, 7 Mar 2016 17:22:52 +0000
Message-ID: <69BFB2EA-BADE-420C-93E5-1320D53EB2C0@gmail.com>
References: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com> <CALx6S36_ii9hOj_Jn+xKxjoZQfbb-TfdQysH-N+Zic-bMHnHPg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35727 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbcCGRXE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:23:04 -0500
Received: by mail-wm0-f42.google.com with SMTP id l68so96390549wml.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 09:23:02 -0800 (PST)
In-Reply-To: <CALx6S36_ii9hOj_Jn+xKxjoZQfbb-TfdQysH-N+Zic-bMHnHPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 24 Feb 2016, at 05:06, Tom Herbert <tom@herbertland.com> wrote:
> 
> On Tue, Feb 23, 2016 at 7:27 AM, Gilberto Bertin
> <gilberto.bertin@gmail.com> wrote:
>> This series introduces support for the SO_BINDTOSUBNET socket option, which
>> allows a listener socket to bind to a subnet instead of * or a single address.
>> 
>> Motivation:
>> consider a set of servers, each one with thousands and thousands of IP
>> addresses. Since assigning /32 or /128 IP individual addresses would be
>> inefficient, one solution can be assigning subnets using local routes
>> (with 'ip route add local').
>> 
> Hi Gilberto,
> 
> The concept is certainly relevant, but allowing binds by subnet seems
> arbitrary. I can imagine that someone might want to bind to a list of
> addresses, list of interfaces, list of subnets, or complex
> combinations like a subnet on one interface, and list of addresses on
> another. So I wonder if this is another use case for a BPF program on
> a listener socket, like a program for a scoring function. Maybe this
> could even combined with  BPF SO_REUSERPORT somehow?
> 
> Tom

Hi Tom,

I have a working POC of the patch that adds support for BPF into the
compute_score function, and I would like to share some thoughts about
advantages and disadvantages of both solutions.

First, setup.

SO_BINDTOSUBET:
- add this to some_server.c:

       subnet.net = addr.s_addr;
       subnet.plen = 24
       setsockopt(sock, SOL_SOCKET, SO_BINDTOSUBNET, &subnet, sizeof(subnet));

and you are done. Your server will accept all connections from the
specified subnet.

BPF_LISTENER_FILTER:
- write a bpf filter like this:

	SEC("socket_bpf")
	int bpf_prog1(struct __sk_buff *skb)
	{
	      unsigned int daddr;
	      daddr = load_word(skb, ETH_HLEN + offsetof(struct iphdr, daddr));

	      if (/* daddr matches subnet */) {
		      return -1; //accept
	      }

	      return 0; // reject
	}

- compile it:
	$ clang -target bpf -c -o socket_bpf.o socket_bpf.c

- add this to your server.c:
	bpf_load_file("/path/to/socket_bpf.o");
	setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, prog_fd, sizeof(prog_fd[0]));

- link your server with a couple of libbpf libraries (I'm
 using the kernel ones from samples/bpf) and -lelf

And this is still simplified (since instead of hardcoding the subnet
into the bpf filter it would be preferable to use maps).


thoughts:
- SO_BINDTOSUBNET is much simpler to configure than BPF
- BPF requires some external C libraries and I think it would not be
 trivial to get it working with other languages than C/C++.
 As an example, I have two working servers for SO_BINDTOSUBNET written
 in Ruby and Go (since both these languages expose setsockopt), but it
 would be necessary to write something that wrap the C libbpf to use
 BPF
- I (personally) do not think SO_BINDTOSUBNET is that much arbitrary, I
 see it more as the logical missing piece between * and a single
 address when calling bind() (otherwise I think we should consider
 arbitrary even SO_BINDTODEVICE)

That said, do you believe it could be an option to maybe have both these
options? I think that the ability to run BPF in the listening path is
really interesting, but it's probably an overkill for the bind-to-subnet
use case.

Thank you,
 gilberto
