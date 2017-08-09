From: "Yang, Yi Y" <yi.y.yang@intel.com>
Subject: RE: [ovs-dev] [PATCH net-next] openvswitch: add NSH support
Date: Wed, 9 Aug 2017 20:12:36 +0000
Message-ID: <79BBBFE6CB6C9B488C1A45ACD284F51961C3C14A@SHSMSX103.ccr.corp.intel.com>
References: <1502168380-106785-1-git-send-email-yi.y.yang@intel.com>
 <20170808162810.1bab3812@griffin>
 <79BBBFE6CB6C9B488C1A45ACD284F51961C391CA@SHSMSX103.ccr.corp.intel.com>
 <20170809024200.GG6175@ovn.org>
 <CFF8EF42F1132E4CBE2BF0AB6C21C58D72735682@ESESSMB107.ericsson.se>
 <79BBBFE6CB6C9B488C1A45ACD284F51961C3ADBE@SHSMSX103.ccr.corp.intel.com>
 <20170809180912.GU6175@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: Jan Scheurich <jan.scheurich@ericsson.com>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        =?iso-8859-1?Q?Zolt=E1n_Balogh?= <zoltan.balogh@ericsson.com>
To: Ben Pfaff <blp@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53503 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752060AbdHIUMl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 16:12:41 -0400
In-Reply-To: <20170809180912.GU6175@ovn.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben, do you mean we bring two new attributes (OVS_NSH_ATTR_MD1 and   OVS_NSH_ATTR_MD2) and embed one of them in OVS_ACTION_ATTR_ENCAP_NSH? Anyway we need to use a struct or something else to transfer those metadata between functions, how do you think we can handle this without metadata in struct ovs_action_encap_nsh? I mean how we handle the arguments for function encap_nsh.

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Pfaff
Sent: Thursday, August 10, 2017 2:09 AM
To: Yang, Yi Y <yi.y.yang@intel.com>
Cc: Jan Scheurich <jan.scheurich@ericsson.com>; dev@openvswitch.org; netdev@vger.kernel.org; Jiri Benc <jbenc@redhat.com>; davem@davemloft.net; Zoltán Balogh <zoltan.balogh@ericsson.com>
Subject: Re: [ovs-dev] [PATCH net-next] openvswitch: add NSH support

On Wed, Aug 09, 2017 at 09:41:51AM +0000, Yang, Yi Y wrote:
> Hi,  Jan
> 
> I have worked out a patch, will send it quickly for Ben. In addition, 
> I also will send out a patch to change encap_nsh &decap_nsh to 
> push_nsh and pop_nsh. Per comments from all the people, we all agreed 
> to do so :-)
> 
> diff --git a/datapath/linux/compat/include/linux/openvswitch.h 
> b/datapath/linux/compat/include/linux/openvswitch.h
> index bc6c94b..4936c12 100644
> --- a/datapath/linux/compat/include/linux/openvswitch.h
> +++ b/datapath/linux/compat/include/linux/openvswitch.h
> @@ -793,7 +793,7 @@ struct ovs_action_push_eth {
>         struct ovs_key_ethernet addresses;  };
> 
> -#define OVS_ENCAP_NSH_MAX_MD_LEN 16
> +#define OVS_ENCAP_NSH_MAX_MD_LEN 248
>  /*
>   * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
>   * @flags: NSH header flags.
> @@ -809,7 +809,7 @@ struct ovs_action_encap_nsh {
>      uint8_t mdlen;
>      uint8_t np;
>      __be32 path_hdr;
> -    uint8_t metadata[OVS_ENCAP_NSH_MAX_MD_LEN];
> +    uint8_t metadata[];
>  };

This brings the overall format of ovs_action_encap_nsh to:

struct ovs_action_encap_nsh {
    uint8_t flags;
    uint8_t mdtype;
    uint8_t mdlen;
    uint8_t np;
    __be32 path_hdr;
    uint8_t metadata[];
};

This is an unusual format for a Netlink attribute.  More commonly, one would put variable-length data into an attribute of its own, which allows that data to be handled using the regular Netlink means.  Then the mdlen and metadata members could be removed, since they would be part of the additional attribute, and one might expect the mdtype member to be removed as well since each type of metadata would be in a different attribute type.

So, a format closer to what I expect to see in Netlink is something like
this:

/**
 * enum ovs_nsh_attr - Metadata attributes for %OVS_ACTION_ENCAP_NSH action.
 *
 * @OVS_NSH_ATTR_MD1: Contains 16-byte NSH type-1 metadata.
 * @OVS_NSH_ATTR_MD2: Contains 0- to 255-byte variable-length NSH type-2
 * metadata. */
enum ovs_nsh_attr {
    OVS_NSH_ATTR_MD1,
    OVS_NSH_ATTR_MD2
};

/*
 * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
 *
 * @path_hdr: NSH service path id and service index.
 * @flags: NSH header flags.
 * @np: NSH next_protocol: Inner packet type.
 *
 * Followed by either %OVS_NSH_ATTR_MD1 or %OVS_NSH_ATTR_MD2 attribute.
 */
struct ovs_action_encap_nsh {
    __be32 path_hdr;
    uint8_t flags;
    uint8_t np;
};
