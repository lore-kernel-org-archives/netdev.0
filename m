From: Edward Cree <ecree@solarflare.com>
Subject: Alignment in BPF verifier
Date: Fri, 19 May 2017 21:00:13 +0100
Message-ID: <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
 <97910214-213c-c5c6-4a02-adc16cd836aa@fb.com>
 <c8e4ce49-5707-3d6d-c8c2-80dd8335d981@solarflare.com>
 <739ef342-728c-de57-c2a2-03fa85b3a246@solarflare.com>
 <17a1c4a2-68d7-0f8f-f009-b97706d67ceb@fb.com>
 <7402a02c-cb00-d48e-1d2a-ccb03356fb72@solarflare.com>
 <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
 <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:50582 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751208AbdESUA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:00:29 -0400
In-Reply-To: <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, I've managed to get somewhat confused by reg->id.
In particular, I'm unsure which bpf_reg_types can have an id, and what
 exactly it means.  There seems to be some code that checks around map value
 pointers, which seems strange as maps have fixed sizes (and the comments in
 enum bpf_reg_type make it seem like id is a PTR_TO_PACKET thing) - is this
 maybe because of map-of-maps support, can the contained maps have differing
 element sizes?  Or do we allow *(map_value + var + imm), if map_value + var
 was appropriately bounds-checked?

Does the 'id' identify the variable that was added to an object pointer, or
 the object itself?  Or does it blur these and identify (what the comment in
 enum bpf_reg_type calls) "skb->data + (u16) var"?

Here's what I'm thinking of doing:
struct bpf_reg_state {
    enum bpf_reg_type type;
    union {
        /* valid when type == PTR_TO_PACKET */
        u16 range;

        /* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
         *   PTR_TO_MAP_VALUE_OR_NULL
         */
        struct bpf_map *map_ptr;
    };
    /* Used to find other pointers with the same variable base, so they
     * can share range and align knowledge.
     */
    u32 id;
    u32 off; /* fixed part of pointer offset */
    /* For scalar types (CONST_IMM | UNKNOWN_VALUE), this represents our
     * knowledge of the actual value.
     * For pointer types, this represents the variable part of the offset
     * from the pointed-to object, and is shared with all bpf_reg_states
     * with the same id as us.
     */
    struct tnum align;
    /* Used to determine if any memory access using this register will
     * result in a bad access. These two fields must be last.
     * See states_equal()
     * These refer to the same value as align, not necessarily the actual
     * contents of the register.
     */
    s64 min_value;
    u64 max_value;
};

Does that sound reasonable?  (And does my added comment on min/max_value
 accurately describe the current semantics, or will I need to change that
 as well?)

-Ed

PS. I think this approach would also mean several of the bpf_reg_types can
 be folded together:
* PTR_TO_MAP_VALUE and PTR_TO_MAP_VALUE_ADJ are the same
* FRAME_PTR is just a PTR_TO_STACK with known-zero offset
* CONST_IMM is similarly a special case of UNKNOWN_VALUE
