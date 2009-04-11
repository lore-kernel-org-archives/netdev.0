From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH v2 15/19] kvm: add dynamic IRQ support
Date: Sat, 11 Apr 2009 20:01:15 +0300
Message-ID: <49E0CCDB.4000806@redhat.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163200.32740.90490.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090409163200.32740.90490.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> This patch provides the ability to dynamically declare and map an
> interrupt-request handle to an x86 8-bit vector.
>
> Problem Statement: Emulated devices (such as PCI, ISA, etc) have
> interrupt routing done via standard PC mechanisms (MP-table, ACPI,
> etc).  However, we also want to support a new class of devices
> which exist in a new virtualized namespace and therefore should
> not try to piggyback on these emulated mechanisms.  Rather, we
> create a way to dynamically register interrupt resources that
> acts indepent of the emulated counterpart.
>
> On x86, a simplistic view of the interrupt model is that each core
> has a local-APIC which can recieve messages from APIC-compliant
> routing devices (such as IO-APIC and MSI) regarding details about
> an interrupt (such as which vector to raise).  These routing devices
> are controlled by the OS so they may translate a physical event
> (such as "e1000: raise an RX interrupt") to a logical destination
> (such as "inject IDT vector 46 on core 3").  A dynirq is a virtual
> implementation of such a router (think of it as a virtual-MSI, but
> without the coupling to an existing standard, such as PCI).
>
> The model is simple: A guest OS can allocate the mapping of "IRQ"
> handle to "vector/core" in any way it sees fit, and provide this
> information to the dynirq module running in the host.  The assigned
> IRQ then becomes the sole handle needed to inject an IDT vector
> to the guest from a host.  A host entity that wishes to raise an
> interrupt simple needs to call kvm_inject_dynirq(irq) and the routing
> is performed transparently.
>
> +static int
> +_kvm_inject_dynirq(struct kvm *kvm, struct dynirq *entry)
> +{
> +	struct kvm_vcpu *vcpu;
> +	int ret;
> +
> +	mutex_lock(&kvm->lock);
> +
> +	vcpu = kvm->vcpus[entry->dest];
> +	if (!vcpu) {
> +		ret = -ENOENT;
> +		goto out;
> +	}
> +
> +	ret = kvm_apic_set_irq(vcpu, entry->vec, 1);
> +
> +out:
> +	mutex_unlock(&kvm->lock);
> +
> +	return ret;
> +}
> +
>   

Given that you're using the apic to inject the IRQ, you'll need an EOI.  
So what's the difference between dynirq and MSI, performance wise?

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

