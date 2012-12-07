From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 06 Dec 2012 17:41:01 -0800
Message-ID: <87y5had4gi.fsf@xmission.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com> <12918.1353190488@obiwan.sandelman.ca>
	<87obivu7n7.fsf@xmission.com>
	<CAOxq_8OC6zUm93mCHD5daxDmuYmmbUdgy0DnjfQdBKky_2t4nQ@mail.gmail.com>
	<87sj7iesdl.fsf@xmission.com>
	<CAOxq_8NbmOtvyH6Q=AVeOUAj7DoFO8cnVUQA5sgyEG7jEJXpHA@mail.gmail.com>
	<87hanyekr3.fsf@xmission.com>
	<alpine.OSX.2.00.1212061730200.58531@animac.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michael Richardson <mcr@sandelman.ca>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: ani@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48163 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423073Ab2LGBlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 20:41:09 -0500
In-Reply-To: <alpine.OSX.2.00.1212061730200.58531@animac.local> (Ani Sinha's
	message of "Thu, 6 Dec 2012 17:31:29 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ani Sinha <ani@aristanetworks.com> writes:

>>
>> The patch is whitespace damaged.  And one of your test is using ||
>> instead of &&
>
> OK, using alpine now :-)
>>
>> The test should be && not ||.
>
> aargh! I am retarded! Fixed. Hopefully 3rd time is a charm :-)

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

The code looks ok here.  I don't know what format the tcpdump folks
want patches in.  The typically format is an email with [PATCH] in
the subject.

You indentation now comes through clear.

It is a bit odd that you are indenting with spaces instead of tabs
in a file that is indented with tab.  Again libpcap isn't my code so I
don't care but someone else might.

Eric


> ani
>
>
>  pcap-linux.c |   50 +++++++++++++++++++++++++++++++-------------------
>  1 files changed, 31 insertions(+), 19 deletions(-)
>
> diff --git a/pcap-linux.c b/pcap-linux.c
> index a42c3ac..b2c1a08 100644
> --- a/pcap-linux.c
> +++ b/pcap-linux.c
> @@ -133,6 +133,7 @@ static const char rcsid[] _U_ =
>  #include <sys/utsname.h>
>  #include <sys/mman.h>
>  #include <linux/if.h>
> +#include <linux/if_packet.h>
>  #include <netinet/in.h>
>  #include <linux/if_ether.h>
>  #include <net/if_arp.h>
> @@ -1543,7 +1544,13 @@ pcap_read_packet(pcap_t *handle, pcap_handler callback, u_char *userdata)
>  				continue;
>
>  			aux = (struct tpacket_auxdata *)CMSG_DATA(cmsg);
> -			if (aux->tp_vlan_tci == 0)
> +#if defined(TP_STATUS_VLAN_VALID)
> +                        if ((aux->tp_vlan_tci == 0) && !(aux->tp_status & TP_STATUS_VLAN_VALID))
> +#else
> +			if (aux->tp_vlan_tci == 0) /* this is ambigious but without the
> +                                                      TP_STATUS_VLAN_VALID flag, there is
> +                                                      nothing that we can do */
> +#endif
>  				continue;
>
>  			len = packet_len > iov.iov_len ? iov.iov_len : packet_len;
> @@ -3936,7 +3926,12 @@ pcap_read_linux_mmap(pcap_t *handle, int max_packets, pcap_handler callback,
>  		}
>
>  #ifdef HAVE_TPACKET2
> -		if (handle->md.tp_version == TPACKET_V2 && h.h2->tp_vlan_tci &&
> +                if ((handle->md.tp_version == TPACKET_V2) &&
> +#if defined(TP_STATUS_VLAN_VALID)
> +                    (h.h2->tp_vlan_tci || (h.h2->tp_status & TP_STATUS_VLAN_VALID)) &&
> +#else
> +                    h.h2->tp_vlan_tci &&
> +#endif
>  		    handle->md.vlan_offset != -1 &&
>  		    tp_snaplen >= (unsigned int) handle->md.vlan_offset) {
>  			struct vlan_tag *tag;
