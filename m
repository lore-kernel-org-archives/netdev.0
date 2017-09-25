From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Mon, 25 Sep 2017 20:50:28 +0200
Message-ID: <59C94FF4.8070900@iogearbox.net>
References: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net> <20170925181000.GA60144@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, peter.waskiewicz.jr@intel.com,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        mchan@broadcom.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60882 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754157AbdIYSui (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 14:50:38 -0400
In-Reply-To: <20170925181000.GA60144@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2017 08:10 PM, Andy Gospodarek wrote:
[...]
> First, thanks for this detailed description.  It was helpful to read
> along with the patches.
>
> My only concern about this area being generic is that you are now in a
> state where any bpf program must know about all the bpf programs in the
> receive pipeline before it can properly parse what is stored in the
> meta-data and add it to an skb (or perform any other action).
> Especially if each program adds it's own meta-data along the way.
>
> Maybe this isn't a big concern based on the number of users of this
> today, but it just starts to seem like a concern as there are these
> hints being passed between layers that are challenging to track due to a
> lack of a standard format for passing data between.

Btw, we do have similar kind of programmable scratch buffer also today
wrt skb cb[] that you can program from tc side, the perf ring buffer,
which doesn't have any fixed layout for the slots, or a per-cpu map
where you can transfer data between tail calls for example, then tail
calls themselves that need to coordinate, or simply mangling of packets
itself if you will, but more below to your use case ...

> The main reason I bring this up is that Michael and I had discussed and
> designed a way for drivers to communicate between each other that rx
> resources could be freed after a tx completion on an XDP_REDIRECT
> action.  Much like this code, it involved adding an new element to
> struct xdp_md that could point to the important information.  Now that
> there is a generic way to handle this, it would seem nice to be able to
> leverage it, but I'm not sure how reliable this meta-data area would be
> without the ability to mark it in some manner.
>
> For additional background, the minimum amount of data needed in the case
> Michael and I were discussing was really 2 words.  One to serve as a
> pointer to an rx_ring structure and one to have a counter to the rx
> producer entry.  This data could be acessed by the driver processing the
> tx completions and callback to the driver that received the frame off the wire
> to perform any needed processing.  (For those curious this would also require a
> new callback/netdev op to act on this data stored in the XDP buffer.)

What you describe above doesn't seem to be fitting to the use-case of
this set, meaning the area here is fully programmable out of the BPF
program, the infrastructure you're describing is some sort of means of
communication between drivers for the XDP_REDIRECT, and should be
outside of the control of the BPF program to mangle.

You could probably reuse the base infra here and make a part of that
inaccessible for the program with some sort of a fixed layout, but I
haven't seen your code yet to be able to fully judge. Intention here
is to allow for programmability within the BPF prog in a generic way,
such that based on the use-case it can be populated in specific ways
and propagated to the skb w/o having to define a fixed layout and
bloat xdp_buff all the way to an skb while still retaining all the
flexibility.

Thanks,
Daniel
